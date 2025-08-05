terraform {
  backend "gcs" {
    bucket = "your-bucket-name" # fill your bucket name
    prefix = "dev/state"
  }
}
