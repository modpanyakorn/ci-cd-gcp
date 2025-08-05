terraform {
  backend "gcs" {
    bucket = "ci-cd-gcp-tf-state" # fill your bucket name
    prefix = "dev/state"
  }
}
