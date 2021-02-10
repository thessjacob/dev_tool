variable "my_user" {
    type    = string
    default = "dev"
}

variable "environment" {
    type    = string
    default = "dev"
}

variable "my_ip" {
    type = string
}

variable "image_id" {
    type    = string
    default = "ami-096fda3c22c1c990a"
}

variable "availability_zone_names" {
    type    = string
    default = "us-east-1"
}

variable "instance_size" {
    type    = string
    default = "t2.micro"    
}
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/23"
}
variable "internal_subnet" {
    type    = string
    default = "10.0.1.0/27"
}

variable "external_subnet" {
    type    = string
    default = "10.0.0.0/27"
}

variable "my_key_name" {
    type    = string
    default = "dev_key"
}

variable "my_key_value" {
    type    = string
}