# launch $1 (first script argument) AWS instances from template defined in $LAUNCH_TEMPLATE set in aws.sh 
#!/bin/bash
set -eu
. aws.sh

numInstances=$1
if [ "$numInstances" == "" ]; then
	echo "Error, number of instances needed as script argument"
	exit 1
fi
aws ec2 run-instances --launch-template LaunchTemplateId=${LAUNCH_TEMPLATE} --count ${numInstances} --query 'Instances[].InstanceId' > .instance_ids_new
cat .instance_ids_new
