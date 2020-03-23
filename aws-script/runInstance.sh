# runInstance.sh: Launches the specified number of instances using an AMI.  Verify all setings in aws.sh first!
#!/bin/bash 
set -eu
. aws.sh

numInstances=$1
if [ "$numInstances" == "" ]; then
	echo "Error, number of instances needed.  Usage: ${0} numInstances"
	exit 1
fi

aws ec2 run-instances --block-device-mappings '[
		    {
                        "DeviceName": "/dev/sdb",
                        "VirtualName": "",
                        "Ebs": {
                            "DeleteOnTermination": true,
                            "VolumeSize": 20,
                            "VolumeType": "gp2"
                        }
                    }
		]'  \
  --image-id "${AWS_IMAGE_ID}" \
  --instance-type "${AWS_INSTANCE_TYPE}" \
  --security-group-ids "${SECURITY_GROUP}" \
  --subnet-id "${SUBNET}" \
  --user-data "${USER_DATA}" \
  --iam-instance-profile "Arn=${IAM_INSTANCE_PROFILE}" \
  --instance-initiated-shutdown-behavior stop \
  --count ${numInstances}  \
  --ebs-optimized \
  --key-name ${AWS_KEY_NAME} \
  --tag-specifications "ResourceType=instance,Tags=[${AWS_TAGS}]" \
  --query 'Instances[].InstanceId' > .instance_ids_new
