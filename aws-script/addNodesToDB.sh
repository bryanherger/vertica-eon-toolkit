# addNodesToDb.sh: add nodes to existing Vertica database.  Run addNodesToCluster.sh first.
#!/bin/bash
set -eu
. aws.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 ip1 ip2 ipN"
    exit 1
fi
ips="$@"
ips=`echo ${ips}|sed 's/ /,/g'`
echo $ips > .expandedIps

ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "admintools -t db_add_node -d ${VSQL_DATABASE} -p ${VSQL_PASSWORD} -a ${ips}"
#vsql -c "select rebalance_shards();"
