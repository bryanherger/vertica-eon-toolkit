# addNodesToCluster.sh: add new nodes to cluster using update_vertica
#!/bin/bash
set -eu
. aws.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 ip1 ip2 ipN"
    exit 1
fi
ips="$@"
for i in ${ips} ; do
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

ips=`echo $ips|sed 's/ /,/g'`
echo $ips
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo /opt/vertica/sbin/update_vertica -A ${ips} -i ${SSH_IDENTITY} --failure-threshold=NONE"
