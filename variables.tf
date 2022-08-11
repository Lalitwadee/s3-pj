
variable "region" {
    default = "ap-southeast-1"
}

variable "account_id" {
    default = "<account_id>"
}

variable "vpc-name" {
  default = "Dev-VPC"
}

variable "bucket-name" {
    type = string
    default = "bucket-dev65"
}

variable "iam-user" {
    default = "rayrai"
}

variable "iam-role" {
    default = "ray"
}

variable "ap-name" {
    default = "rayrai-ap"
}

variable "gw-name" {
  default = "Gateway-Dev"
}

#-----------------------------------

variable "tag-value-bucket" {
    default = "s3-private"
}

variable "versioning_s3" {
    default = "Disabled"
}

variable "oject_owner" {
    description = "Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced"
    default = "BucketOwnerPreferred"
}
