
variable "gce_ssh_user" {
	default = "taamallah_sabri"
}
variable "gce_ssh_pub_key_file" {
	default = "~/.ssh/google_compute_engine.pub"
}

variable "google_credential" {
	default = " /home/taamallah_sabri/advskill-d14811d88477.json"
}

variable "google_project" {
	default = "advskill-225022"
}

variable "google_region" {
	default = "europe-west2"
}

variable "google_zone" {
	default = "europe-west2-b"
}


variable "google_type"{
	type = "string"
	default = "n1-standard-1"
}

variable "google_image_boot"{
	type = "string"
	default = "ubuntu-1804-bionic-v20181222"
}


