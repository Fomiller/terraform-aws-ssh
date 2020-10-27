

variable "ssh_port" {
  description = "The port the EC2 Instance should listen on for SSH requests."
  type        = number
  default     = 22
}

variable "ssh_user" {
  description = "SSH user name to use for remote exec connections,"
  type        = string
  default     = "ec2-user"
}

variable "docker_image" {
  description = "Name of docker image to be run on instance,"
  type        = string
  default     = "fomiller/ng-hero"
}