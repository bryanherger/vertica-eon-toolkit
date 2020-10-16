#!/bin/bash
# NEW='10.142.0.19,10.142.0.17,10.142.0.18,10.142.0.20'
NEW=$1
GCSAUTH=$2
COMMUNAL=$3
DBNAME=$4
DBPW=$5
DBLIC=${6:-CE}
OLD=`cat ips.txt`
if [ -z "$OLD" ]; then
  echo New cluster
  sudo /opt/vertica/sbin/install_vertica -i /home/dbadmin/gcp.key -L $DBLIC -Y --failure-threshold NONE -s $NEW
  echo gcsauth = $GCSAUTH >> /opt/vertica/config/admintools.conf
  sudo -u dbadmin /opt/vertica/bin/admintools -t revive_db -d $DBNAME --communal-storage-location=$COMMUNAL -s $NEW
  sudo -u dbadmin /opt/vertica/bin/admintools -t start_db -d $DBNAME -p $DBPW
  echo $NEW > /home/dbadmin/ips.txt
  exit
fi
# ${varName//Pattern/Replacement}
NEW=${NEW//,/ }
OLD=${OLD//,/ }
echo "input: NEW='$NEW' OLD='$OLD'"
for w in $NEW; do
  if ! echo "$OLD" | grep -q "$w" ; then
    added=1
    DELTA="$DELTA $w"
  fi
done
for w in $OLD; do
  if ! echo "$NEW" | grep -q "$w" ; then
    removed=1
    DELTA="$DELTA $w"
  fi
done
NEW=${NEW// /,}
OLD=${OLD// /,}
### Trim leading whitespaces ###
DELTA="${DELTA##*( )}"
DELTA="$(echo -e "${DELTA}" | sed -e 's/^[[:space:]]*//')"
DELTA=${DELTA// /,}
if [ "$added" ]; then
  echo "added: NEW='$NEW' OLD='$OLD' DELTA='$DELTA'"
  exit
fi
if [ "$removed" ]; then
  echo "removed: NEW='$NEW' OLD='$OLD' DELTA='$DELTA'"
  exit
fi
echo "no change: NEW='$NEW' OLD='$OLD'"


