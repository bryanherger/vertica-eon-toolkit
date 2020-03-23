# shrinkCluster.sh: remove nodes from DB then remove hosts from cluster.  Does NOT remove subcluster definition currently.
#!/bin/bash
set -eu
. aws.sh

removeDBNodes() {
    nodes=$1
    ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "admintools  -t db_remove_node -d ${VSQL_DATABASE}  -p '${VSQL_PASSWORD}' -i -s ${nodes}"
    vsql -c "select rebalance_shards()";

}

removeClusterNodes() {
    nodes=$1
    ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo /opt/vertica/sbin/update_vertica --remove-hosts ${nodes} -i ~/.ssh/id_rsa"
}

terminateInstances() {
    ips=$1
    instances=`aws ec2 describe-instances --filter "Name=private-ip-address,Values=${ips}" "Name=network-interface.subnet-id,Values=$SUBNET" --query 'Reservations[].Instances[].InstanceId'`
    aws ec2 terminate-instances --instance-ids "${instances}"
    echo "Instances $instances terminated"
}


ips=$1
####ips=`cat .expandedIps`

dbIps=$ips
if [ "${ips}" == "" ]; then
	echo "Error, please provide the list private ip addresses to remove separated by ,"
	echo "Usage ${0} ipCSV"
	exit 1
fi

remainingNodes=${ips}
nodesToRemove=${ips}
numberOfNodes=`echo "${remainingNodes}"|sed 's/,/ /g'|wc -w`
finalCount=`vsql -XAt -c "select count(1)-$numberOfNodes from nodes;"`
if [ ${finalCount} -lt 3  ]; then
	echo "Error, removing $ips would leave the cluster with less than 3 nodes."
	exit 1
fi
	
####while [ ${numberOfNodes} -gt 0 ]; do
####	maxNumberOfNodes=`vsql -XAt -c "select round(count(1)/2)::int-1 from nodes;"`
	####maxNumberOfNodes=3
	

	####nodesToRemove=`echo "${remainingNodes}"|cut -d,  -f 1-${maxNumberOfNodes}`
	####remainingNodes=`echo ${remainingNodes}|sed -e "s/${nodesToRemove}//g" -e "s/^,//g"`
	echo "removing $nodesToRemove"
	####echo "remaining $remainingNodes"
	removeDBNodes ${nodesToRemove}
	sleep 10
	####numberOfNodes=`echo "${remainingNodes}"|sed 's/,/ /g'|wc -w`
####done

	
./removeClusterNodes.sh ${ips}
./terminateInstances.sh ${ips}
