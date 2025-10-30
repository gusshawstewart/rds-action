# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

variable "db_instance_identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "RDS database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "RDS database engine version"
  type        = string
  default     = "17.2"  # Default for PostgreSQL, but will be overridden by Port
}

variable "username" {
  description = "RDS database username"
  type        = string
  default     = "admin"  # Generic default that works for most engines
}