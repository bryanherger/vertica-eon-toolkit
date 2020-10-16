variable "gcp_project" {
  default = "vertica-sandbox"
}

variable "gcp_region" {
  default = "us-east1"
}

variable "gcp_machine_type" {
  default = "n1-standard-2"
}

variable "gcp_zone" {
  default = "us-east1-c"
}

variable "cluster_member_count" {
  description = "Number of members in the cluster"
  default = "3"
}

// generate keypair with "ssh-keygen -f gcp.key"
// then connect with ssh -i gcp.key dbadmin@<public ip>
variable "vertica_keypair_privatekey_filepath" {
  description = "Path to SSH private key to SSH-connect to instances"
  default = "./gcp.key"
}

variable "vertica_keypair_publickey_filepath" {
  description = "Path to SSH public key to SSH-connect to instances"
  default = "./gcp.key.pub"
}

variable "vertica_gcsauth" {
  default = "X:Y"
}

variable "vertica_communal" {
  default = "gs://X/Y"
}

variable "vertica_dbname" {
  default = "eongcp"
}

variable "vertica_dbpw" {
  default = "XYZ"
}

variable "vertica_license" {
  # default CE sets Community Edition with 3 nodes and 1 TB. Set file here and uncomment provisioner in main.tf to use more TB / more nodes
  default = "CE"
}

