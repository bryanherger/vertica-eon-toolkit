# wakeupDB.sh: revive a stopped or hibernating database (previously stopped with sleepDB.sh)
#!/bin/bash
set -eu
. aws.sh

ips=`cat .sleep_ips`
if [ "$ips" == "" ];then 
	if [ $# -ne 1 ]; then
		echo "Error: No ip addresses provided and .sleep_ips file empty"
		echo "Usage: $0 ip1,ip2,ipN"
    		exit 1
	else
		$ips="$1"
	fi
fi

instances=`aws ec2 describe-instances --filter "Name=private-ip-address,Values=${ips}" "Name=network-interface.subnet-id,Values=$SUBNET" --query 'Reservations[].Instances[].InstanceId'`
aws ec2 start-instances --instance-ids "${instances}"
sleep 60

./waitForInstances.sh "${instances}"

for i in `echo ${ips}|sed 's/,/ /g'` ; do
    while true; do 
	md=`ssh -i ${SSH_KEY} -o "StrictHostKeyChecking no" $i df -h /vertica/data|grep md|wc -l`
	if [ "${md}" -lt "1" ]; then
	    echo "Host $i not ready. Waiting"
	    sleep 10
        else   
	    echo "Host $i ready."
	    break
	fi
    done
done



ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "admintools -t drop_db -d ${VSQL_DATABASE}"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "admintools -t revive_db  -s ${ips}  --communal-storage-location=${S3_PATH} -d ${VSQL_DATABASE}"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "admintools -t start_db -d ${VSQL_DATABASE} -p '${VSQL_PASSWORD}'"
ips=`echo $ips|sed 's/,/ /g'`
echo ${ips}
for i in $ips; do
    echo $i
    cat warmUp.sql |ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "vsql -w '${VSQL_PASSWORD}' -h $i" > /dev/null

done
time ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "vsql -w '${VSQL_PASSWORD}' -c 'select finish_fetching_files()'"
