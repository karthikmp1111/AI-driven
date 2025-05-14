terraform {
  backend "s3" {
    bucket = "kar-weather-s3"
    key    = "terraform-state/terraform.tfstate"
    region = "us-west-1"
  }
}
