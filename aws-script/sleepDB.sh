# sleepDB.sh: cleanly stop Vertica and stop all node instances (does not terminate, so instances and EBS will persist)
# creates .sleep_ip file to be used by wakeupDB.sh to restore this database
#!/bin/bash
set -eu
. aws.sh

#ips=$1
#vsql -c "SELECT SET_CONFIG_PARAMETER('MaxClientSessions', 0);"
ips=`vsql  -XAt -c "select node_address from nodes"`
ips=`echo $ips|sed 's/ /,/g'`
echo "$ips" > .sleep_ips
instances=`aws ec2 describe-instances --filter "Name=private-ip-address,Values=${ips}" "Name=network-interface.subnet-id,Values=$SUBNET" --query 'Reservations[].Instances[].InstanceId'`

vsql -c "select close_all_sessions();"
sleep 10
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "admintools -t stop_db -d ${VSQL_DATABASE} -p '${VSQL_PASSWORD}'  -i -F " 

aws ec2 stop-instances --instance-ids "${instances}"
