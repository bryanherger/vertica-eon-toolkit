# createSubcluster.sh: create a new subcluster.  This will add hosts to DB and add the new nodes to the subcluster in one script.
#!/bin/bash
set -eu
. aws.sh

if [ $# -ne 2 ]; then
	echo "Usage $0 ip1,ip2,...,ipN SubClusterName"
	exit 1
fi
ips=${1}
faultGroup=${2}
# use admintools to add subcluster
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo /opt/vertica/sbin/update_vertica -A ${ips} -i ${SSH_IDENTITY} --failure-threshold=NONE"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "/opt/vertica/bin/admintools -t db_add_subcluster -s ${ips} --is-secondary -c ${faultGroup} -d ${VSQL_DATABASE} -p ${VSQL_PASSWORD}"

