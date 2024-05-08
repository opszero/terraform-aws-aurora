provider "aws" {
  region = "eu-west-1"
}

locals {
  environment = "test"
  name        = "aurora-postgres-serverless"
}

module "vpc" {
  source      = "cypik/vpc/aws"
  version     = "1.0.1"
  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]

  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source      = "cypik/subnet/aws"
  version     = "1.0.1"
  name        = "subnets"
  environment = "test"
  label_order = ["name", "environment"]

  nat_gateway_enabled = true

  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
  #  assign_ipv6_address_on_creation = false
}


##-----------------------------------------------------------------------------
## PostgreSQL Serverless
##-----------------------------------------------------------------------------
module "aurora_postgresql" {
  source          = "../../"
  name            = local.name
  environment     = local.environment
  engine          = "aurora-postgresql"
  engine_mode     = "provisioned"
  engine_version  = "14.5"
  master_username = "root"
  database_name   = "postgres"
  vpc_id          = module.vpc.id
  subnets         = module.subnets.public_subnet_id
  allowed_ports   = [5432]
  allowed_ip      = [module.vpc.vpc_cidr_block, ]

  monitoring_interval = 60
  apply_immediately   = true
  skip_final_snapshot = true
  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }
  instance_class = "db.serverless"
  instances = {
    one = {
      publicly_accessible = true

    }
    two = {
      publicly_accessible = true

    }
  }
}
