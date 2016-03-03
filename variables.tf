variable "aws_region" {
    default = "eu-west-1" 
}

variable "aws_coreos_ami" {
    default = "ami-7e72c70d"
}

variable "aws_vpc_name" {
    default = "ci"
}

variable "aws_availability_zones" {
    default = "eu-west-1a,eu-west-1b,eu-west-1c"
}

variable "route53_zone_id" {
    # default = "FASD1234FASD1234"
}

variable "route53_domain" {
    # default = "example.com"
}

variable "ssh_key_name" {
    # default = "your.key.name"
}

variable "office_subnet" {
    # default = "1.2.3.4/32"
}
