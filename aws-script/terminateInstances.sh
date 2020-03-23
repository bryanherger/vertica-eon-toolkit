# terminateInstances.sh: terminate AWS instances based on list of node private IP's
#!/bin/bash
set -eu
. aws.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 [ ip0,ip1,...,ipN ]"
    exit 1
fi
ips=$1
instances=`aws ec2 describe-instances --filter "Name=private-ip-address,Values=${ips}" "Name=network-interface.subnet-id,Values=$SUBNET" --query 'Reservations[].Instances[].InstanceId'`
aws ec2 terminate-instances --instance-ids "${instances}"
echo "Instances $instances terminated"
