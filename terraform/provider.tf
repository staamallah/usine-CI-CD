
provider "google" {
  credentials = "${file("../../advskill-225022-03c20e56a292.json")}"
  project  = "${var.google_project}"
  region  = "${var.google_region}"
  zone  = "${var.google_zone}"
}



