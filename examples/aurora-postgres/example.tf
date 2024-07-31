provider "aws" {
  region = local.region
}

locals {
  name        = "aurora-postgres"
  environment = "test"
  label_order = ["environment", "name"]
  region      = "eu-west-1"
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

  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}


##-----------------------------------------------------------------------------
## RDS Aurora Module
##-----------------------------------------------------------------------------
module "aurora-postgresql" {
  source = "../../"

  name        = local.name
  environment = local.environment
  label_order = local.label_order

  engine          = "aurora-postgresql"
  engine_version  = "16.1"
  master_username = "root"
  database_name   = "postgres"
  storage_type    = "aurora-iopt1"
  allowed_ports   = [5432]
  allowed_ip      = ["0.0.0.0/0"]
  subnets         = module.subnets.public_subnet_id
  vpc_id          = module.vpc.id
  instances = {
    1 = {
      instance_class      = "db.t4g.medium"
      publicly_accessible = true
    }
    2 = {
      identifier          = "static-member-1"
      instance_class      = "db.t4g.large"
      publicly_accessible = true
    }
    3 = {
      identifier          = "excluded-member-1"
      instance_class      = "db.t3.medium"
      promotion_tier      = 15
      publicly_accessible = true

    }
  }

  apply_immediately                      = true
  skip_final_snapshot                    = true
  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "aurora-postgres"
  db_cluster_parameter_group_family      = "aurora-postgresql16"
  db_cluster_parameter_group_description = "aurora postgres example cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    },
    {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    }
  ]
  create_db_parameter_group      = true
  db_parameter_group_name        = "aurora-postgre"
  db_parameter_group_family      = "aurora-postgresql16"
  db_parameter_group_description = "postgres aurora example DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]
  enabled_cloudwatch_logs_exports = ["postgresql"]

  ##-------------------------------------
  ## RDS PROXY
  ##-------------------------------------
  create_db_proxy  = true
  engine_family    = "POSTGRESQL"
  proxy_subnet_ids = module.subnets.public_subnet_id
  auth = [
    {
      auth_scheme = "SECRETS"
      description = "example"
      iam_auth    = "DISABLED"
      secret_arn  = module.aurora-postgresql.cluster_master_user_secret[0].secret_arn
    }
  ]
}
