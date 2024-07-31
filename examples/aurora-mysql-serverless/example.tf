provider "aws" {
  region = "eu-north-1"
}

locals {
  environment = "test"
  name        = "aurora-mysql-serverless"
}

module "vpc" {
  source      = "opszero/vpc/aws"
  version     = "1.0.1"
  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]

  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source      = "opszero/subnet/aws"
  version     = "1.0.1"
  name        = "subnets"
  environment = "test"
  label_order = ["name", "environment"]

  nat_gateway_enabled = true

  availability_zones = ["eu-north-1a", "eu-north-1b"]
  vpc_id             = module.vpc.id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

##-----------------------------------------------------------------------------
## MySQL Serverless
##-----------------------------------------------------------------------------
module "aurora_mysql" {
  source          = "../../"
  name            = local.name
  environment     = local.environment
  engine          = "aurora-mysql"
  engine_mode     = "provisioned"
  engine_version  = "8.0"
  master_username = "root"
  database_name   = "test"
  sg_ids          = []
  allowed_ports   = [3306]
  allowed_ip      = [module.vpc.vpc_cidr_block]
  vpc_id          = module.vpc.id
  subnets         = module.subnets.public_subnet_id

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

