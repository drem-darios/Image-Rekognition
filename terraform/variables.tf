variable "github_repository" {
  type    = string
  default = "Image-Rekognition"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "app_vpc_id" {
  type    = string
}

variable "account_id" {
  type    = string
}

variable "tags" {
  type = object({
    Environment = string
    GithubRepo   = string
  })
}

variable "s3_tempory_upload_expiration" {
  type    = string
  default = "3600"
}
