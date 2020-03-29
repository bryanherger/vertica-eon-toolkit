# createSpotSubcluster.sh: create a new subcluster.  This will request spot instances, add hosts to DB, and add the new nodes to the subcluster in one script.
#!/bin/bash
set -eu
. aws.sh

if [ $# -ne 2 ]; then
	echo "Usage $0 InstanceCount SubClusterName"
	exit 1
fi

icount=${1}
subCluster=${2}
launchGroup=${subCluster}_`date +%s`
echo ${launchGroup} > ${subCluster}.lgid
# step 1: request spot instances
# part A build launch template.  You WILL need to modify this to match your AWS - required items include security groups, subnets, VPC...
# see docs at https://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-instances.html
echo -e \{\"ImageId\":\"${AWS_IMAGE_ID}\",\"SecurityGroupIds\":[\"${SECURITY_GROUP}\"],\"KeyName\":\"${AWS_KEY_NAME}\",\"InstanceType\":\"${AWS_INSTANCE_TYPE}\",\"NetworkInterfaces\":\[\{\"DeviceIndex\":0,\"AssociatePublicIpAddress\":true\,\"SubnetId\":\"${SUBNET}\"}\]\} > spec.json

# part B launch
aws ec2 request-spot-instances --instance-count ${icount} --launch-specification file://spec.json --launch-group ${launchGroup}
sleep 15

# step 2: configure disks and OS on spot instances
# part A get public and private IP's
ids=`aws ec2 describe-spot-instance-requests --filter "Name=launch-group,Values=${launchGroup}" --query 'SpotInstanceRequests[].InstanceId'`
echo ${ids}
# aws ec2 describe-instances --filter "Name=instance-id,Values=${instances}"
ips=`aws ec2 describe-instances --instance-ids "${ids}" --query 'Reservations[].Instances[].PrivateIpAddress' --output table|grep "[[0-9]]*"|sed -e 's/|//g' -e 's/ //g'`
echo ${ips}
publicips=`aws ec2 describe-instances --instance-ids "${ids}" --query 'Reservations[].Instances[].PublicIpAddress' --output table|grep "[[0-9]]*"|sed -e 's/|//g' -e 's/ //g'`
echo ${publicips}

# part B build LVM - this is designed for i3 instances and needs to be modified for other types!
for i in `echo ${ips}|sed 's/,/ /g'` ; do
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo mkdir /vertica
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo pvcreate /dev/nvme?n1
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo vgcreate vg_vertica /dev/nvme?n1
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo lvcreate -l 100%VG -n lv_vertica vg_vertica
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo mkfs.ext4 /dev/vg_vertica/lv_vertica
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo mount /dev/vg_vertica/lv_vertica /vertica
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i df -h
    ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i sudo chown -R dbadmin:verticadba /vertica
done

# step 3: add new hosts to cluster, then add to database
# we got private IP's of new spot instances above, so update_vertica with the new hosts then use admintools to add subcluster
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo /opt/vertica/sbin/update_vertica -A ${ips} -i ${SSH_IDENTITY} --failure-threshold=NONE"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "/opt/vertica/bin/admintools -t db_add_subcluster -s ${ips} --is-secondary -c ${subCluster} -d ${VSQL_DATABASE} -p ${VSQL_PASSWORD}"
# final: return the external IP address of a subcluster host for SQL connections
echo Cluster ${subCluster} is ready, connect to one of ${publicips}
