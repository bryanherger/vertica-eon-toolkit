# destroySpotSubcluster.sh: remove a new subcluster and shut down the associated spot instances.
#!/bin/bash
set -eu
. aws.sh

if [ $# -ne 1 ]; then
	echo "Usage $0 SubClusterName"
	exit 1
fi

subCluster=${1}
launchGroup=`cat ${subCluster}.lgid`
# step 1: cancel spot instances
ids=`aws ec2 describe-spot-instance-requests --filter "Name=launch-group,Values=${launchGroup}" --query 'SpotInstanceRequests[].InstanceId'`
echo ${ids}
# get private IP's
# aws ec2 describe-instances --filter "Name=instance-id,Values=${instances}"
ips=`aws ec2 describe-instances --instance-ids "${ids}" --query 'Reservations[].Instances[].PrivateIpAddress' --output table|grep "[[0-9]]*"|sed -e 's/|//g' -e 's/ //g'`
echo ${ips}
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "/opt/vertica/bin/admintools -t db_remove_subcluster -c ${subCluster} -d ${VSQL_DATABASE} -p ${VSQL_PASSWORD}"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo /opt/vertica/sbin/update_vertica -R ${ips} -i ${SSH_IDENTITY} --failure-threshold=NONE"

# step 2: cancel spot instances
sirids=`aws ec2 describe-spot-instance-requests --filter "Name=launch-group,Values=${launchGroup}" --query 'SpotInstanceRequests[].SpotInstanceRequestId'`
aws ec2 cancel-spot-instance-requests --spot-instance-request-ids "${sirids}"

