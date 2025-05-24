variable "mydomain" {
  type = string
  default = "doratar.com"
}

variable "mydomain_www" {
  type = string
  default = "www.doratar.com"
}

variable "bucket_name" {
  type = string
  default = "dor-resume"
}

variable "region" {
  type = string
  default = "il-central-1"
}

variable "resource_path" {
  default = "visitors"
}