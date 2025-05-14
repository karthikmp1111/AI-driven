terraform {
  backend "s3" {
    bucket = "kar-weather-s3"
    key    = "terraform-state/lambda/terraform.tfstate"
    region = "us-west-1"
  }
}
