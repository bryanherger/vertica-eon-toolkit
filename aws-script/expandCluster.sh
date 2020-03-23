# expandCluster.sh: single script to start a number (param 1) of new instances, add them to cluster, then add new nodes to DB or subcluster (param 2)
#!/bin/bash
set -eu
. aws.sh

numInstances=$1
if [ "$numInstances" == "" ]; then
	echo "Error, number of instances needed.  Usage: ${0} numInstances [subcluster]"
	exit 1
fi
./runInstance.sh $numInstances

echo "Created instances. Waiting 1 minute for AWS"
sleep 60
ids=`cat .instance_ids_new`
if [ "${ids}" == "" ]; then
   echo "Error: Something went wrong while creating instances, or instance ids not captured in file"
   exit 1
fi

./waitForInstances.sh "${ids}"

ips=`aws ec2 describe-instances --instance-ids "${ids}" --query 'Reservations[].Instances[].PrivateIpAddress' --output table|grep "[[0-9]]*"|sed -e 's/|//g' -e 's/ //g'`

./addNodesToCluster.sh "${ips}"
./addNodesToDB.sh "${ips}"
if [ $# -eq 2 ]; then
    ./createSubcluster.sh "${ips}" $2
fi
vsql -c "select rebalance_shards();"


	 


	  
	  
