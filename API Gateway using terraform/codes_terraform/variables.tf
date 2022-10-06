variable "env" {
  type = string
  default = "dev"
}

variable "aws_region" {
  type = string
  default = "us_east_1"
}

variable "aws_account_id" {
  type = string
  default = "insertIDAccountHere" //for obvious reasons, I will not enter a valid account id here, but you will have to
}

variable "service_name" {
  type = string
  default = "users"
}