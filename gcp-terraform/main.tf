// Configure the Google Cloud provider
provider "google" {
 credentials = file("gcp_credentials.json")
 project     = "${var.gcp_project}"
 region      = "${var.gcp_region}"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "vertica" {
 count        = var.cluster_member_count
 name         = "vertica-vm-${random_id.instance_id.hex}-${count.index+1}"
 machine_type = "${var.gcp_machine_type}"
 zone         = "${var.gcp_zone}"

 metadata = {
   ssh-keys = "dbadmin:${file(var.vertica_keypair_publickey_filepath)}"
 }

 boot_disk {
   initialize_params {
     image = "https://www.googleapis.com/compute/v1/projects/vertica-public-163918/global/images/vertica-10-0-1-0-centos-7-6-mcga"
   }
 }

// Make sure dialog is installed on all new instances for later steps
 metadata_startup_script = "sudo yum -y update; sudo yum -y install dialog nano;"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }

  service_account {
    scopes = ["storage-full","service-control"]
  }
}

resource "google_compute_firewall" "vertica" {
 name    = "vertica-db-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["5433"]
 }
}

output "network_ip" {
 value = google_compute_instance.vertica.*.network_interface.0.network_ip
}

output "nat_ip" {
 value = google_compute_instance.vertica.*.network_interface.0.access_config.0.nat_ip
}

output "nat_ip_0" {
 value = google_compute_instance.vertica.0.network_interface.0.access_config.0.nat_ip
}

output "ip_list" {
 value = join(",", formatlist("%v", google_compute_instance.vertica.*.network_interface.0.network_ip))
}

# Bash command to populate /etc/hosts file on each instances
resource "null_resource" "provision_vertica_cluster" {
  # we really only need to run this on the first node

  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", google_compute_instance.vertica.*.id)}"
  }

  connection {
    type = "ssh"
    host = "${google_compute_instance.vertica.0.network_interface.0.access_config.0.nat_ip}"
    user = "dbadmin"
    private_key = "${file(var.vertica_keypair_privatekey_filepath)}"
  }
  provisioner "file" {
    source      = "gcp.key"
    destination = "/tmp/gcp.key"
  }
/*
// uncomment this block and provide correct locations to use a license other than CE
  provisioner "file" {
    source      = "vertica.license"
    destination = "${var.vertica_license}"
  }
*/
  provisioner "remote-exec" {
    inline = [
      "sudo /opt/vertica/sbin/install_vertica -i /tmp/gcp.key -L ${var.vertica_license} -Y --failure-threshold NONE -s ${join(",", formatlist("%v", google_compute_instance.vertica.*.network_interface.0.network_ip))}",
      "echo gcsauth = ${var.vertica_gcsauth} >> /opt/vertica/config/admintools.conf",
      "/opt/vertica/bin/admintools -t revive_db -d ${var.vertica_dbname} --communal-storage-location=${var.vertica_communal} -s ${join(",", formatlist("%v", google_compute_instance.vertica.*.network_interface.0.network_ip))}",
      "/opt/vertica/bin/admintools -t start_db -d ${var.vertica_dbname} -p ${var.vertica_dbpw}",
    ]
  }
}

