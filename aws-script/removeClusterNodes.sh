# removeClusterNodes.sh: remove hosts from cluster.  Remove the associated nodes from any subcluster or DB first.
#!/bin/bash
set -eu
. aws.sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 ip1,ip2,ipN"
    exit 1
fi
    
nodes=$1
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo /opt/vertica/sbin/update_vertica --failure-threshold=NONE --remove-hosts ${nodes} -i ~/.ssh/id_rsa"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "echo $nodes|sed 's/,/|/g' > .tgrep"
ssh -i ${SSH_KEY} dbadmin@${VSQL_HOST} "sudo -- bash -c \"grep -v -E -f $HOME/.tgrep ~/.ssh/known_hosts > ~/.ssh/known_hosts.new; mv ~/.ssh/known_hosts.new ~/.ssh/known_hosts\""
echo $nodes|sed 's/,/|/g' > .tgrep
grep -v -E -f .tgrep ~/.ssh/known_hosts > ~/.ssh/known_hosts.new; mv ~/.ssh/known_hosts.new ~/.ssh/known_hosts
#mv ~/.ssh/known_hosts.new ~/.ssh/known_hosts"

