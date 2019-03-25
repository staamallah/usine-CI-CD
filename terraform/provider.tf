
provider "google" {
  credentials = "${var.google_credential}"
  project  = "${var.google_project}"
  region  = "${var.google_region}"
  zone  = "${var.google_zone}"
}



