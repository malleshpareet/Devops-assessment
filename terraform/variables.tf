variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default = "ap-south-1"
}

variable "key_name" {
  description = "Name of the existing EC2 Key Pair to allow SSH access"
  type        = string
  default     = "devops-key" # Change this to your real key pair name
}
