# aws.sh: common variables and functions for Vertica scripts.
export SSH_IDENTITY="~/.ssh/id_rsa"
export VSQL_PASSWORD='dbadmin'
export VSQL_HOST=10.11.12.228
export VSQL_DATABASE=VerticaDB1
export SUBNET="subnet-0744675da12be7a6e"
export S3_PATH="s3://carlos-tests/vmartdemo1"
export SECURITY_GROUP="sg-06f47fb40ac453656"
export AWS_INSTANCE_TYPE="i3.4xlarge"
export AWS_IMAGE_ID="ami-06c2146b67eff1970"
export IAM_INSTANCE_PROFILE="arn:aws:iam::139258803600:instance-profile/Carlos_1552328599018_402"
#export USER_DATA=`base64 -w0 userData.sh`
export USER_DATA="file://$PWD/userData.sh"
export AWS_KEY_NAME="Carlos"
export AWS_TAGS="{Key=Name,Value=vertica_demo1_expand}"
export SSH_KEY="/opt/vconsole/config/vaid_rsa"
