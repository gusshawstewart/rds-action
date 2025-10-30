# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

# Use default VPC to avoid VPC limits
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Local variables for dynamic parameter group family
locals {
  # Map engine versions to parameter group families for different engines
  postgres_family_map = {
    "11"    = "postgres11"
    "11.9"  = "postgres11"
    "11.21" = "postgres11"
    "12"    = "postgres12"
    "12.17" = "postgres12"
    "13"    = "postgres13"
    "13.13" = "postgres13"
    "14"    = "postgres14"
    "14.9"  = "postgres14"
    "15"    = "postgres15"
    "15.4"  = "postgres15"
    "16"    = "postgres16"
    "16.1"  = "postgres16"
    "17"    = "postgres17"
    "17.2"  = "postgres17"
  }

  mysql_family_map = {
    "5.7"  = "mysql5.7"
    "8.0"  = "mysql8.0"
  }

  # Default ports for different engines
  engine_ports = {
    postgres   = 5432
    mysql      = 3306
    sqlserver  = 1433
    oracle     = 1521
  }
  
  # Extract major version from engine_version for fallback
  major_version = split(".", var.engine_version)[0]
  
  # Determine parameter group family based on engine
  parameter_group_family = (
    var.engine == "postgres" ? lookup(local.postgres_family_map, var.engine_version, "postgres${local.major_version}") :
    var.engine == "mysql" ? lookup(local.mysql_family_map, var.engine_version, "mysql${local.major_version}") :
    var.engine == "sqlserver" ? "sqlserver-ex-15.0" :
    var.engine == "oracle" ? "oracle-ee-19" : "postgres17"
  )
  
  # Get the appropriate port for the engine
  db_port = lookup(local.engine_ports, var.engine, 5432)
}

resource "aws_db_subnet_group" "education" {
  name       = "${var.db_instance_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.db_instance_identifier}-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.db_instance_identifier}-rds-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_instance_identifier}-rds-sg"
  }
}

resource "aws_db_parameter_group" "education" {
  name   = "${var.db_instance_identifier}-param-group"
  family = local.parameter_group_family

  # Common parameter that works across most engines
  dynamic "parameter" {
    for_each = var.engine == "postgres" ? [1] : []
    content {
      name  = "log_connections"
      value = "1"
    }
  }

  dynamic "parameter" {
    for_each = var.engine == "mysql" ? [1] : []
    content {
      name  = "general_log"
      value = "1"
    }
  }
}

resource "aws_db_instance" "education" {
  identifier             = var.db_instance_identifier
  instance_class         = var.instance_class
  allocated_storage      = 5
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}