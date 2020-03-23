# userData.sh: this is base64-encoded and passed to new instances in the UserData field.  It runs at first start to configure some OS and system settings to Vertica recommendations.
#!/bin/bash 
set -x 
exec 1> >(tee -a /root/run_once.log) 2>&1 
# added to assist vertica install 
# set the root volume scheduler and read ahead options correctly 
echo noop >  /sys/block/xvda/queue/scheduler 
/sbin/blockdev --setra 2048 /dev/xvda1 
systemctl start chronyd  
systemctl status chronyd
# Create new dbadmin user
[ 'dbadmin' != dbadmin ] && useradd dbadmin -g verticadba
# remove old device mappings
umount /mnt 
sed -i "/vertica\/data/d;/dev\/xvd/d" /etc/fstab 
# Setup the disk raid
echo Yes | sh /opt/vertica/sbin/configure_aws_software_raid.sh -u dbadmin -t EPH -m /vertica/data -d /dev/nvme0n1,/dev/nvme1n1,/dev/nvme2n1,/dev/nvme3n1,/dev/nvme4n1,/dev/nvme5n1,/dev/nvme6n1,/dev/nvme7n1
if [ EON == 'EON' ]; then
  sudo ln -s /vertica/data /scratch_b
fi 
# connect all the instance
#sudo bash -c "nc -l 5433 >> /home/dbadmin/.ssh/authorized_keys"
[ 'dbadmin' != dbadmin ] && sudo cp -r /home/dbadmin/.ssh /home/dbadmin/.ssh; sudo chown -R dbadmin:verticadba /home/dbadmin/.ssh
sudo echo 'dbadmin      ALL=(ALL)      NOPASSWD:ALL' > /etc/sudoers.d/vertica  

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQtr3Yn0W4/+tuLTrKcjYsbQhOWZR/LqqthjIjLzoK6DpqpH1a3caQI76wC7Qhv2PgIFn03OP3P7gfMBXHb+YNUzLNpqC7xzgchB2mIKQMkEDnOCG0pzQY2KRdrX5mv3WpxPk2UQAn1Gx3pBR9eBufGUwlzPvjeeX3LDhZleUqA3MIkK2SnpgAIhQzs21+C7D6mZKtEv64OrUjFgsjb5704QFZ/5PeW0hqBiILnFrw1cUxZeoyDR7wNPQdquxW9EojQ6Gqc6P1DM36A8NalGFkBPilcOvJBprDigaQdf3Qc9QqYsWP1dP9V/l3r5XpwMjVxXi7YKEodBv16jcj/8OtYsNF0KEkyzBg+vrjMy9e05eXJWG8gKPGBsgevTNZQ7uOQBbABo0tzFzt9i6QZM4drs2/e2iQJqHV11bxhTwRODYxbbfAay2s1heZtf971/Top1SDY0y532aaN7JFYDvZF1xclc20QR1pL5U3KhRQ8PUqLJ31dOMz0rKYsvN1QBBOIftkJu/qyL7tqN5a+kgnlSF3GNzfv0T+p4OBPXiS25KJqQLneDf6mrKr/bwuC3NEpbBcXudtO1XI8/qM6fY2NaptwTaElqMplUbxUWPSX85OofsJPILb5sy5FjUIVVQd9MEHp6+oQbbqkUs4SeJma5m6re0wn6b5u3fDiJ1dEw== Carlos
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDi/gjYMuS8F+5zeUP7kUdo65UdG/luRz12Gvn6nL0hHzBT/8GuZmOqCZSmC84kwclJ9aYuCnN+BJle76HpnsNRw4B9AjTq+TbDWbPAAtmg4KuvpXpcKoD4Aqocdhy6knF/K2k4gecdEFQQTMGU1QbUcv62giDLF1GS8o3iJoVfFWbYIP96D+ciTdT33NrVppomk9LtBux9pPE9+feafg/Yv3x5YlHXX3on20nY8YIC0lqkDtD7iPbAx3QOLPFfGP1sRgF86lmgQgV21YyqW70dJMRDiJOPTz+gZRm58y3OjfO29QofaU0cPIh1WXTisYGUk21mj3GBNVHxMA3KQJE9
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHoQPX59udO53r0qu5WfTudiQphF1EpOSFRwCx3kzQXYLQq97JwYhPx1mjJmUYuk8mtuKfYwRNPKDykGl/5GPItpcXObPlmwFWEBxRwGMBE5dJjX3xlgL7Z79FUgWR1o7DnCQGsFsOEEW1iAcmD2goxMDZZlqiHbU6pp1kJHD4awyl4jvR7qksOzpFl7uOPrEOWfHXkKbkku47BlscsFWehwMXoqsE9xChOuLrtYHpv6U2zWpWneaC3pZ3qw267D5IQpi+W2DzyoTXQMu2prdK7xqNYGIyJmsKDR3Q36G75x8kefxDXL5Z9a18oNf7pkogBesBKBjm0+DoIiiSTCdn dbadmin@ip-10-11-12-221.ec2.internal
' >>  /home/dbadmin/.ssh/authorized_keys
# All done

