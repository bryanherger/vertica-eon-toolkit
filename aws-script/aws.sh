# aws.sh: common variables and functions for Vertica scripts.  Run from MC or Vertica cluster node, be sure SSH_KEY is set correctly
# Use "aws configure" to set access keys, or use IAM user/role.
export SSH_IDENTITY="~/.ssh/id_rsa"
export VSQL_PASSWORD='dbadmin'
export VSQL_HOST=10.11.12.228
export VSQL_DATABASE=VerticaDB1
export SUBNET="subnet-0744675da12be7a6e"
export S3_PATH="s3://carlos-tests/vmartdemo1"
export SECURITY_GROUP="sg-06f47fb40ac453656"
export AWS_INSTANCE_TYPE="i3.4xlarge"
# this is for Vertica 9.3.1-2 BYOL.  (marketplace: 8erxyt4005krhlsdidhzbfbpt)
# Edit as needed to use newer version OR hourly license (need to subscribe is AWS Marketplace to use AMI either way)
export AWS_IMAGE_ID="ami-05c08427801571a43"
export IAM_INSTANCE_PROFILE="arn:aws:iam::139258803600:instance-profile/Carlos_1552328599018_402"
#export USER_DATA=`base64 -w0 userData.sh`
export USER_DATA="file://$PWD/userData.sh"
export AWS_KEY_NAME="VerticaToolbox"
export AWS_TAGS="{Key=Name,Value=vertica_demo1_expand}"
export SSH_KEY="/opt/vconsole/config/vaid_rsa"
