terraform {
  backend "s3" {
    bucket = "kar-weather-s3"
    key    = "terraform-states/terraform.tfstate"
    region = "us-west-1"
  }
}
