
resource "google_compute_network" "default"{
	name = "terraform-kubernetes-the-hard-way"
	auto_create_subnetworks = "false"
}


resource "google_compute_subnetwork" "default"{
	name ="terraform-kubernetes"
	network = "${google_compute_network.default.name}"
	ip_cidr_range = "10.250.0.0/24"
}


resource "google_compute_firewall" "firewall_internal"{

	name = "terraform-kubernetes-the-hard-way-allow-internal"
	network = "${google_compute_network.default.name}"

	allow{
	   protocol = "icmp"
	}
	allow{
	   protocol = "udp"
	}
	allow{
	   protocol = "tcp"
	}
	source_ranges = ["10.250.0.0/24", "10.150.0.0/16"]
}


resource "google_compute_firewall" "firewall_external"{

	name = "terraform-kubernetes-the-hard-way-allow-external"
	network = "${google_compute_network.default.name}"

	allow{
	   protocol = "icmp"
	}
	allow{
	   protocol = "udp"
	}
	allow{
	   protocol = "tcp"
	   ports = ["22", "6443"]
	}
	source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_address" "default"{
	name= "terraform-kubernetes-the-hard-way"
}


resource "google_compute_instance" "controller"{
        count = 3
	name = "terraform-controller-${count.index}"
	machine_type = "${var.google_type}"
	zone = "${var.google_zone}"
	can_ip_forward = true
	tags = ["terraform-kubernetes-the-hard-way", "controller"]
	boot_disk {
		initialize_params {
	
			image = "${var.google_image_boot}"
			size = "100"
		}
	}
	network_interface {
		subnetwork = "${google_compute_subnetwork.default.name}"
		network_ip = "10.250.0.1${count.index}"

	access_config {
      // Ephemeral IP
	 }
}
	service_account{
		scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write","monitoring"]
	}
	metadata = {
    	sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

metadata_startup_script = "apt-get install -y python"

}

resource "google_compute_instance" "worker"{
	count = 3
	name = "terraform-worker-${count.index}"
	machine_type = "${var.google_type}"
	zone = "${var.google_zone}"
	can_ip_forward = true
	tags = ["terraform-kubernetes-the-hard-way", "worker"]
	boot_disk {
		initialize_params {
			image = "${var.google_image_boot}"
			size = "100"
		}
	}
	network_interface {
		subnetwork = "${google_compute_subnetwork.default.name}"
		network_ip = "10.250.0.2${count.index}"
	 access_config {
      // Ephemeral IP
    	}
	}
	service_account{
		scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write","monitoring"]
	}
	metadata = { 
		pod-cidr = "10.150.${count.index}.0/24"	
   		sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

}
