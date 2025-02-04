variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Machine Image ID for EC2"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Example for us-east-1
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "my-key"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "my-ec2-instance"
}