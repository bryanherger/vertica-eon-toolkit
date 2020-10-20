## Manage Vertica on Google Cloud Platform (GCP) with Terraform

### Prerequisites

You must create a Vertica database in Eon mode and stop/hibernate it.  This Terraform module will revive and operate the database.

Obtain and fill all values in variables.tf.  To apply a license, you may also need to edit the provisioner in main.tf

### Quick start

Edit variables.tf

`terraform apply`

To change number of nodes, `terraform apply -var 'cluster_member_count=X'`

You should stop the cluster manually - run `admintools -t stop_db` or execute `SELECT SHUTDOWN();` as dbadmin - before destroying the Terraform resources.
