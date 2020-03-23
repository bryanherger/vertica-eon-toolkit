# waitForInstances.sh: wait for instances to start (does not mean they will accept connections! but should not take much longer)
#!/bin/bash
set -eu
. aws.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 [ \"instanceId1\",\"instanceId\",...,\"instanceIdN\" ]"
    exit 1
fi
ids="${1}"
while true; do
    ###aws ec2 describe-instances --instance-ids "${ids}" --query 'Reservations[].Instances[].State.Code' --output table|grep "[[0-9]]*" > .instance_status
    n=`aws ec2 describe-instance-status --instance-ids "${ids}"  --query 'InstanceStatuses[].InstanceStatus.Status' --output text|tr '[:space:]' '\n'|grep -v "ok"|wc -l`
      if [ "${n}" -gt 0 ]; then
	  echo "Waiting for instances"
	  sleep 10
      else
	  echo "done"
	  break;
      fi
done
