# Terraform-aws-aurora

# Terraform AWS Cloud aurora DB Module

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Examples](#Examples)
- [Author](#Author)
- [License](#license)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Introduction
This Terraform module creates an AWS Aurora Database Service- AWS (DB) along with additional configuration options.
## Usage
To use this module, you can include it in your Terraform configuration. Here's an example of how to use it:

## Examples

## Example: aurora-mysql

```hcl
module "aurora-mysql" {
  source          = "cypik/aurora/aws"
  version         = "1.0.0"
  name            = local.name
  environment     = local.environment
  engine          = "aurora-mysql"
  engine_version  = "8.0"
  master_username = "root"
  database_name   = "test"
  sg_ids          = []
  allowed_ports   = [3306]
  allowed_ip      = [module.vpc.vpc_cidr_block]
  instances = {
    1 = {
      instance_class      = "db.r5.large"
      publicly_accessible = true
    }
    2 = {
      identifier          = "mysql-static-1"
      instance_class      = "db.r5.2xlarge"
      publicly_accessible = true
    }
    3 = {
      identifier     = "mysql-excluded-1"
      instance_class = "db.r5.xlarge"
      promotion_tier = 15
    }
  }

  apply_immediately   = true
  skip_final_snapshot = true
  subnets             = module.subnets.public_subnet_id
  vpc_id              = module.vpc.id

  create_db_cluster_parameter_group = true
  db_cluster_parameter_group_name   = "aurora-mysql"
  db_cluster_parameter_group_family = "aurora-mysql8.0"
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 120
      apply_method = "immediate"
    }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
    }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
    }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
    }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
    }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }, {
      name         = "require_secure_transport"
      value        = "ON"
      apply_method = "immediate"
    }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = "aurora-mysql"
  db_parameter_group_family      = "aurora-mysql8.0"
  db_parameter_group_description = "mysql aurora example DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 60
      apply_method = "immediate"
    }, {
      name         = "general_log"
      value        = 0
      apply_method = "immediate"
    }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
    }, {
      name         = "long_query_time"
      value        = 5
      apply_method = "immediate"
    }, {
      name         = "max_connections"
      value        = 2000
      apply_method = "immediate"
    }, {
      name         = "slow_query_log"
      value        = 1
      apply_method = "immediate"
    }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }
  ]

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}
```
## Example: aurora-mysql-serverless
```hcl
module "aurora_mysql" {
  source          = "cypik/aurora/aws"
  version         = "1.0.0"
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
```

## Example: aurora-postgresql
```hcl
module "aurora-postgresql" {
  source      = "cypik/aurora/aws"
  version     = "1.0.0"
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
```

## Example: aurora-postgresql-serverless
```hcl
module "aurora_postgresql" {
  source          = "cypik/aurora/aws"
  version         = "1.0.0"
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
```

## Example
For detailed examples on how to use this module, please refer to the [examples](https://github.com/cypik/terraform-aws-aurora/tree/master/examples) directory within this repository.

## Author
Your Name Replace **MIT** and **Cypik** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

## License
This project is licensed under the **MIT** License - see the [LICENSE](https://github.com/cypik/terraform-aws-aurora/blob/master/LICENSE) file for details.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.31.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.31.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | cypik/labels/aws | 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_proxy.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy) | resource |
| [aws_db_proxy_default_target_group.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group) | resource |
| [aws_db_proxy_endpoint.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_endpoint) | resource |
| [aws_db_proxy_target.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target) | resource |
| [aws_db_subnet_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_role.proxy_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.proxy_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_rds_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_endpoint) | resource |
| [aws_rds_cluster_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_rds_cluster_role_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_role_association) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_id.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_iam_policy_document.monitoring_rds_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.proxy_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.proxy_iam_policy_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster. (This setting is required to create a Multi-AZ DB cluster) | `number` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions. Defaults to `false` | `bool` | `false` | no |
| <a name="input_allowed_ip"></a> [allowed\_ip](#input\_allowed\_ip) | List of allowed ip. | `list(any)` | `[]` | no |
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | List of allowed ingress ports | `list(any)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false` | `bool` | `null` | no |
| <a name="input_auth"></a> [auth](#input\_auth) | n/a | `any` | `{}` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true` | `bool` | `null` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Determines whether autoscaling of the cluster read replicas is enabled | `bool` | `false` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of read replicas permitted when autoscaling is enabled | `number` | `2` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of read replicas permitted when autoscaling is enabled | `number` | `0` | no |
| <a name="input_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#input\_autoscaling\_policy\_name) | Autoscaling policy name | `string` | `"target-metric"` | no |
| <a name="input_autoscaling_scale_in_cooldown"></a> [autoscaling\_scale\_in\_cooldown](#input\_autoscaling\_scale\_in\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale in | `number` | `300` | no |
| <a name="input_autoscaling_scale_out_cooldown"></a> [autoscaling\_scale\_out\_cooldown](#input\_autoscaling\_scale\_out\_cooldown) | Cooldown in seconds before allowing further scaling operations after a scale out | `number` | `300` | no |
| <a name="input_autoscaling_target_connections"></a> [autoscaling\_target\_connections](#input\_autoscaling\_target\_connections) | Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max\_connections | `number` | `700` | no |
| <a name="input_autoscaling_target_cpu"></a> [autoscaling\_target\_cpu](#input\_autoscaling\_target\_cpu) | CPU threshold which will initiate autoscaling | `number` | `70` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply | `list(string)` | `null` | no |
| <a name="input_backtrack_window"></a> [backtrack\_window](#input\_backtrack\_window) | The target backtrack window, in seconds. Only available for `aurora` engine currently. To disable backtracking, set this value to 0. Must be between 0 and 259200 (72 hours) | `number` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The days to retain backups for. Default `7` | `number` | `7` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance | `string` | `null` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_members"></a> [cluster\_members](#input\_cluster\_members) | List of RDS Instances that are a part of this cluster | `list(string)` | `null` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of tags to add to only the cluster. Used for AWS Instance Scheduler tagging | `map(string)` | `{}` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Create, update, and delete timeout configurations for the cluster | `map(string)` | `{}` | no |
| <a name="input_connection_borrow_timeout"></a> [connection\_borrow\_timeout](#input\_connection\_borrow\_timeout) | (Optional) The number of seconds for a proxy to wait for a connection to become available in the connection pool. Only applies when the proxy has opened its maximum number of connections and all connections are busy with client sessions. | `number` | `null` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy all Cluster `tags` to snapshots | `bool` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether cluster should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_db_cluster_parameter_group"></a> [create\_db\_cluster\_parameter\_group](#input\_create\_db\_cluster\_parameter\_group) | Determines whether a cluster parameter should be created or use existing | `bool` | `false` | no |
| <a name="input_create_db_parameter_group"></a> [create\_db\_parameter\_group](#input\_create\_db\_parameter\_group) | Determines whether a DB parameter should be created or use existing | `bool` | `false` | no |
| <a name="input_create_db_proxy"></a> [create\_db\_proxy](#input\_create\_db\_proxy) | (Optional) Set this to true to create RDS Proxy. | `bool` | `false` | no |
| <a name="input_create_monitoring_role"></a> [create\_monitoring\_role](#input\_create\_monitoring\_role) | Determines whether to create the IAM role for RDS enhanced monitoring | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for an automatically created database on cluster creation | `string` | `""` | no |
| <a name="input_db_cluster_db_instance_parameter_group_name"></a> [db\_cluster\_db\_instance\_parameter\_group\_name](#input\_db\_cluster\_db\_instance\_parameter\_group\_name) | Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `allow_major_version_upgrade` | `string` | `null` | no |
| <a name="input_db_cluster_instance_class"></a> [db\_cluster\_instance\_class](#input\_db\_cluster\_instance\_class) | The compute and memory capacity of each DB instance in the Multi-AZ DB cluster, for example db.m6g.xlarge. Not all DB instance classes are available in all AWS Regions, or for all database engines | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_description"></a> [db\_cluster\_parameter\_group\_description](#input\_db\_cluster\_parameter\_group\_description) | The description of the DB cluster parameter group. Defaults to "Managed by Terraform" | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_family"></a> [db\_cluster\_parameter\_group\_family](#input\_db\_cluster\_parameter\_group\_family) | The family of the DB cluster parameter group | `string` | `""` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | The name of the DB cluster parameter group | `string` | `null` | no |
| <a name="input_db_cluster_parameter_group_parameters"></a> [db\_cluster\_parameter\_group\_parameters](#input\_db\_cluster\_parameter\_group\_parameters) | A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other | `list(map(string))` | `[]` | no |
| <a name="input_db_parameter_group_description"></a> [db\_parameter\_group\_description](#input\_db\_parameter\_group\_description) | The description of the DB parameter group. Defaults to "Managed by Terraform" | `string` | `null` | no |
| <a name="input_db_parameter_group_family"></a> [db\_parameter\_group\_family](#input\_db\_parameter\_group\_family) | The family of the DB parameter group | `string` | `""` | no |
| <a name="input_db_parameter_group_name"></a> [db\_parameter\_group\_name](#input\_db\_parameter\_group\_name) | The name of the DB parameter group | `string` | `null` | no |
| <a name="input_db_parameter_group_parameters"></a> [db\_parameter\_group\_parameters](#input\_db\_parameter\_group\_parameters) | A list of DB parameters to apply. Note that parameters may differ from a family to an other | `list(map(string))` | `[]` | no |
| <a name="input_debug_logging"></a> [debug\_logging](#input\_debug\_logging) | (Optional) Whether the proxy includes detailed information about SQL statements in its logs. This information helps you to debug issues involving SQL behavior or the performance and scalability of the proxy connections. The debug information includes the text of SQL statements that you submit through the proxy. Thus, only enable this setting when needed for debugging, and only when you have security measures in place to safeguard any sensitive information that appears in the logs. | `bool` | `false` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false` | `bool` | `null` | no |
| <a name="input_egress_protocol"></a> [egress\_protocol](#input\_egress\_protocol) | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `number` | `-1` | no |
| <a name="input_egress_rule"></a> [egress\_rule](#input\_egress\_rule) | Enable to create egress rule | `bool` | `true` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| <a name="input_enable_default_proxy_iam_role"></a> [enable\_default\_proxy\_iam\_role](#input\_enable\_default\_proxy\_iam\_role) | (OPTIONAL) Set this to false to pass your own IAM Role for RDS Proxy. | `bool` | `true` | no |
| <a name="input_enable_global_write_forwarding"></a> [enable\_global\_write\_forwarding](#input\_enable\_global\_write\_forwarding) | Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an `aws_rds_global_cluster`'s primary cluster | `bool` | `null` | no |
| <a name="input_enable_http_endpoint"></a> [enable\_http\_endpoint](#input\_enable\_http\_endpoint) | Enable HTTP endpoint (data API). Only valid when engine\_mode is set to `serverless` | `bool` | `null` | no |
| <a name="input_enable_security_group"></a> [enable\_security\_group](#input\_enable\_security\_group) | Enable default Security Group with only Egress traffic allowed. | `bool` | `true` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql` | `list(string)` | `[]` | no |
| <a name="input_enabled_subnet_group"></a> [enabled\_subnet\_group](#input\_enabled\_subnet\_group) | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | Map of additional cluster endpoints and their attributes to be created | `any` | `{}` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql` | `string` | `null` | no |
| <a name="input_engine_family"></a> [engine\_family](#input\_engine\_family) | (Required, Forces new resource) The kinds of databases that the proxy can connect to. This value determines which database network protocol the proxy recognizes when it interprets network traffic to and from the database. For Aurora MySQL, RDS for MariaDB, and RDS for MySQL databases, specify MYSQL. For Aurora PostgreSQL and RDS for PostgreSQL databases, specify POSTGRESQL. For RDS for Microsoft SQL Server, specify SQLSERVER. Valid values are MYSQL, POSTGRESQL, and SQLSERVER. | `string` | `"POSTGRESQL"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned` | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The database engine version. Updating this argument results in an outage | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made | `string` | `null` | no |
| <a name="input_from_port"></a> [from\_port](#input\_from\_port) | (Required) Start port (or ICMP type number if protocol is icmp or icmpv6). | `number` | `0` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | The global cluster identifier specified on `aws_rds_global_cluster` | `string` | `null` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the monitoring role | `string` | `null` | no |
| <a name="input_iam_role_force_detach_policies"></a> [iam\_role\_force\_detach\_policies](#input\_iam\_role\_force\_detach\_policies) | Whether to force detaching any policies the monitoring role has before destroying it | `bool` | `null` | no |
| <a name="input_iam_role_managed_policy_arns"></a> [iam\_role\_managed\_policy\_arns](#input\_iam\_role\_managed\_policy\_arns) | Set of exclusive IAM managed policy ARNs to attach to the monitoring role | `list(string)` | `null` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | Maximum session duration (in seconds) that you want to set for the monitoring role | `number` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path for the monitoring role | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the monitoring role | `string` | `null` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | Map of IAM roles and supported feature names to associate with the cluster | `map(map(string))` | `{}` | no |
| <a name="input_idle_client_timeout"></a> [idle\_client\_timeout](#input\_idle\_client\_timeout) | (Optional) The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it. You can set this value higher or lower than the connection timeout limit for the associated database. | `number` | `1800` | no |
| <a name="input_init_query"></a> [init\_query](#input\_init\_query) | (Optional) One or more SQL statements for the proxy to run when opening each new database connection. Typically used with SET statements to make sure that each connection has identical settings such as time zone and character set. This setting is empty by default. For multiple statements, use semicolons as the separator. You can also include multiple variables in a single SET statement, such as SET x=1, y=2. | `string` | `""` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling | `string` | `""` | no |
| <a name="input_instance_timeouts"></a> [instance\_timeouts](#input\_instance\_timeouts) | Create, update, and delete timeout configurations for the cluster instance(s) | `map(string)` | `{}` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Map of cluster instances and any specific/overriding attributes to be created | `any` | `{}` | no |
| <a name="input_instances_use_identifier_prefix"></a> [instances\_use\_identifier\_prefix](#input\_instances\_use\_identifier\_prefix) | Determines whether cluster instance identifiers are used as prefixes | `bool` | `false` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster | `number` | `null` | no |
| <a name="input_ipv6_cidr_blocks"></a> [ipv6\_cidr\_blocks](#input\_ipv6\_cidr\_blocks) | Enable to create egress rule | `list(string)` | <pre>[<br>  "::/0"<br>]</pre> | no |
| <a name="input_is_primary_cluster"></a> [is\_primary\_cluster](#input\_is\_primary\_cluster) | Determines whether cluster is primary cluster with writer instance (set to `false` for global cluster and replica clusters) | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true` | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if `master_password` is provided | `bool` | `true` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'cypik'. | `string` | `"cypik"` | no |
| <a name="input_master_user_secret_kms_key_id"></a> [master\_user\_secret\_kms\_key\_id](#input\_master\_user\_secret\_kms\_key\_id) | The Amazon Web Services KMS key identifier is the key ARN, key ID, alias ARN, or alias name for the KMS key | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database | `string` | `null` | no |
| <a name="input_max_connections_percent"></a> [max\_connections\_percent](#input\_max\_connections\_percent) | (Optional) The maximum size of the connection pool for each target in a target group. For Aurora MySQL, it is expressed as a percentage of the max\_connections setting for the RDS DB instance or Aurora DB cluster used by the target group. | `number` | `100` | no |
| <a name="input_max_idle_connections_percent"></a> [max\_idle\_connections\_percent](#input\_max\_idle\_connections\_percent) | (Optional) Controls how actively the proxy closes idle database connections in the connection pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy to close idle client connections and return the underlying database connections to the connection pool. For Aurora MySQL, it is expressed as a percentage of the max\_connections setting for the RDS DB instance or Aurora DB cluster used by the target group. | `number` | `null` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disable. Default is `0` | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | IAM role used by RDS to send enhanced monitoring metrics to CloudWatch | `string` | `""` | no |
| <a name="input_monitoring_role_name"></a> [monitoring\_role\_name](#input\_monitoring\_role\_name) | Name of the IAM role which will be created when create\_monitoring\_role is enabled. | `string` | `"rds-monitoring-role"` | no |
| <a name="input_mysql_iam_role_tags"></a> [mysql\_iam\_role\_tags](#input\_mysql\_iam\_role\_tags) | Additional tags for the mysql iam role | `map(any)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | n/a | yes |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | The type of network stack to use (IPV4 or DUAL) | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not | `bool` | `null` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years) | `number` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the DB accepts connections | `string` | `null` | no |
| <a name="input_predefined_metric_type"></a> [predefined\_metric\_type](#input\_predefined\_metric\_type) | The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections` | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC | `string` | `"02:00-03:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The weekly time range during which system maintenance can occur, in (UTC) | `string` | `"sun:05:00-sun:06:00"` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | The protocol. If not icmp, tcp, udp, or all use the. | `string` | `"tcp"` | no |
| <a name="input_proxy_endpoints"></a> [proxy\_endpoints](#input\_proxy\_endpoints) | Map of DB proxy endpoints to create and their attributes (see `aws_db_proxy_endpoint`) | `any` | `{}` | no |
| <a name="input_proxy_iam_role_description"></a> [proxy\_iam\_role\_description](#input\_proxy\_iam\_role\_description) | Description of the monitoring role | `string` | `null` | no |
| <a name="input_proxy_iam_role_path"></a> [proxy\_iam\_role\_path](#input\_proxy\_iam\_role\_path) | Path for the monitoring role | `string` | `null` | no |
| <a name="input_proxy_role_arn"></a> [proxy\_role\_arn](#input\_proxy\_role\_arn) | (OPTIONAL) ARN of RDS proxy IAM Role. Can only be set when `enable_default_proxy_iam_role` is set to `false`. | `string` | `""` | no |
| <a name="input_proxy_sg_ids"></a> [proxy\_sg\_ids](#input\_proxy\_sg\_ids) | (Optional) One or more VPC security group IDs to associate with the new proxy. | `list(string)` | `[]` | no |
| <a name="input_proxy_subnet_ids"></a> [proxy\_subnet\_ids](#input\_proxy\_subnet\_ids) | (Required) One or more VPC subnet IDs to associate with the new proxy. | `list(string)` | `[]` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Determines whether instances are publicly accessible. Default `false` | `bool` | `false` | no |
| <a name="input_replication_source_identifier"></a> [replication\_source\_identifier](#input\_replication\_source\_identifier) | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica | `string` | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/cypik/terraform-aws-aurora"` | no |
| <a name="input_require_tls"></a> [require\_tls](#input\_require\_tls) | (Optional) A Boolean parameter that specifies whether Transport Layer Security (TLS) encryption is required for connections to the proxy. By enabling this setting, you can enforce encrypted TLS connections to the proxy. | `bool` | `false` | no |
| <a name="input_restore_to_point_in_time"></a> [restore\_to\_point\_in\_time](#input\_restore\_to\_point\_in\_time) | Map of nested attributes for cloning Aurora cluster | `map(string)` | `{}` | no |
| <a name="input_s3_import"></a> [s3\_import](#input\_s3\_import) | Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported) | `map(string)` | `{}` | no |
| <a name="input_scaling_configuration"></a> [scaling\_configuration](#input\_scaling\_configuration) | Map of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless` | `map(string)` | `{}` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned` | `map(string)` | `{}` | no |
| <a name="input_session_pinning_filters"></a> [session\_pinning\_filters](#input\_session\_pinning\_filters) | (Optional) Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection. Including an item in the list exempts that class of SQL operations from the pinning behavior. Currently, the only allowed value is EXCLUDE\_VARIABLE\_SETS. | `list(string)` | `[]` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | The security group description. | `string` | `"Instance default security group (only egress access is allowed)."` | no |
| <a name="input_sg_egress_description"></a> [sg\_egress\_description](#input\_sg\_egress\_description) | Description of the egress and ingress rule | `string` | `"Description of the rule."` | no |
| <a name="input_sg_egress_ipv6_description"></a> [sg\_egress\_ipv6\_description](#input\_sg\_egress\_ipv6\_description) | Description of the egress\_ipv6 rule | `string` | `"Description of the rule."` | no |
| <a name="input_sg_ids"></a> [sg\_ids](#input\_sg\_ids) | of the security group id. | `list(any)` | `[]` | no |
| <a name="input_sg_ingress_description"></a> [sg\_ingress\_description](#input\_sg\_ingress\_description) | Description of the ingress rule | `string` | `"Description of the ingress rule use elasticache."` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot | `string` | `null` | no |
| <a name="input_source_region"></a> [source\_region](#input\_source\_region) | The source region for an encrypted replica DB cluster | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. The default is `true` | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Specifies the storage type to be associated with the DB cluster. (This setting is required to create a Multi-AZ DB cluster). Valid values: `io1`, Default: `io1` | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs used by database subnet group created | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_to_port"></a> [to\_port](#input\_to\_port) | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `number` | `65535` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where to create security group | `string` | `""` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of VPC security groups to associate to the cluster in addition to the security group created | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_cluster_endpoints"></a> [additional\_cluster\_endpoints](#output\_additional\_cluster\_endpoints) | A map of additional cluster endpoints and their attributes |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_cluster_database_name"></a> [cluster\_database\_name](#output\_cluster\_database\_name) | Name for an automatically created database on cluster creation |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Writer endpoint for the cluster |
| <a name="output_cluster_engine_version_actual"></a> [cluster\_engine\_version\_actual](#output\_cluster\_engine\_version\_actual) | The running version of the cluster database |
| <a name="output_cluster_hosted_zone_id"></a> [cluster\_hosted\_zone\_id](#output\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The RDS Cluster Identifier |
| <a name="output_cluster_instances"></a> [cluster\_instances](#output\_cluster\_instances) | A map of cluster instances and their attributes |
| <a name="output_cluster_master_password"></a> [cluster\_master\_password](#output\_cluster\_master\_password) | The database master password |
| <a name="output_cluster_master_user_secret"></a> [cluster\_master\_user\_secret](#output\_cluster\_master\_user\_secret) | The generated database master user secret when `manage_master_user_password` is set to `true` |
| <a name="output_cluster_master_username"></a> [cluster\_master\_username](#output\_cluster\_master\_username) | The database master username |
| <a name="output_cluster_members"></a> [cluster\_members](#output\_cluster\_members) | List of RDS Instances that are a part of this cluster |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The database port |
| <a name="output_cluster_reader_endpoint"></a> [cluster\_reader\_endpoint](#output\_cluster\_reader\_endpoint) | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_cluster_role_associations"></a> [cluster\_role\_associations](#output\_cluster\_role\_associations) | A map of IAM roles associated with the cluster and their attributes |
| <a name="output_db_cluster_parameter_group_arn"></a> [db\_cluster\_parameter\_group\_arn](#output\_db\_cluster\_parameter\_group\_arn) | The ARN of the DB cluster parameter group created |
| <a name="output_db_cluster_parameter_group_id"></a> [db\_cluster\_parameter\_group\_id](#output\_db\_cluster\_parameter\_group\_id) | The ID of the DB cluster parameter group created |
| <a name="output_db_parameter_group_arn"></a> [db\_parameter\_group\_arn](#output\_db\_parameter\_group\_arn) | The ARN of the DB parameter group created |
| <a name="output_db_parameter_group_id"></a> [db\_parameter\_group\_id](#output\_db\_parameter\_group\_id) | The ID of the DB parameter group created |
| <a name="output_enhanced_monitoring_iam_role_arn"></a> [enhanced\_monitoring\_iam\_role\_arn](#output\_enhanced\_monitoring\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the enhanced monitoring role |
| <a name="output_enhanced_monitoring_iam_role_name"></a> [enhanced\_monitoring\_iam\_role\_name](#output\_enhanced\_monitoring\_iam\_role\_name) | The name of the enhanced monitoring role |
| <a name="output_enhanced_monitoring_iam_role_unique_id"></a> [enhanced\_monitoring\_iam\_role\_unique\_id](#output\_enhanced\_monitoring\_iam\_role\_unique\_id) | Stable and unique string identifying the enhanced monitoring role |
| <a name="output_proxy_arn"></a> [proxy\_arn](#output\_proxy\_arn) | The Amazon Resource Name (ARN) for the proxy |
| <a name="output_proxy_default_target_group_arn"></a> [proxy\_default\_target\_group\_arn](#output\_proxy\_default\_target\_group\_arn) | The Amazon Resource Name (ARN) for the default target group |
| <a name="output_proxy_default_target_group_id"></a> [proxy\_default\_target\_group\_id](#output\_proxy\_default\_target\_group\_id) | The ID for the default target group |
| <a name="output_proxy_default_target_group_name"></a> [proxy\_default\_target\_group\_name](#output\_proxy\_default\_target\_group\_name) | The name of the default target group |
| <a name="output_proxy_endpoint"></a> [proxy\_endpoint](#output\_proxy\_endpoint) | The endpoint that you can use to connect to the proxy |
| <a name="output_proxy_iam_policy_name"></a> [proxy\_iam\_policy\_name](#output\_proxy\_iam\_policy\_name) | The name of the policy attached to RDS Proxy IAM Role. |
| <a name="output_proxy_iam_role_arn"></a> [proxy\_iam\_role\_arn](#output\_proxy\_iam\_role\_arn) | Amazon Resource Name (ARN) specifying the RDS Proxy role. |
| <a name="output_proxy_iam_role_name"></a> [proxy\_iam\_role\_name](#output\_proxy\_iam\_role\_name) | Name of the RDS Proxy IAM Role. |
| <a name="output_proxy_iam_role_unique_id"></a> [proxy\_iam\_role\_unique\_id](#output\_proxy\_iam\_role\_unique\_id) | Stable and unique string identifying the RDS Proxy role. |
| <a name="output_proxy_id"></a> [proxy\_id](#output\_proxy\_id) | The ID of the rds proxy |
| <a name="output_proxy_name"></a> [proxy\_name](#output\_proxy\_name) | Identifier representing the DB Instance or DB Cluster target |
| <a name="output_proxy_target_endpoint"></a> [proxy\_target\_endpoint](#output\_proxy\_target\_endpoint) | Hostname for the target RDS DB Instance. Only returned for `RDS_INSTANCE` type |
| <a name="output_proxy_target_id"></a> [proxy\_target\_id](#output\_proxy\_target\_id) | Identifier of `db_proxy_name`, `target_group_name`, target type (e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER`), and resource identifier separated by forward slashes (/) |
| <a name="output_proxy_target_port"></a> [proxy\_target\_port](#output\_proxy\_target\_port) | Port for the target RDS DB Instance or Aurora DB Cluster |
| <a name="output_proxy_target_target_arn"></a> [proxy\_target\_target\_arn](#output\_proxy\_target\_target\_arn) | Amazon Resource Name (ARN) for the DB instance or DB cluster. Currently not returned by the RDS API |
| <a name="output_proxy_target_tracked_cluster_id"></a> [proxy\_target\_tracked\_cluster\_id](#output\_proxy\_target\_tracked\_cluster\_id) | DB Cluster identifier for the DB Instance target. Not returned unless manually importing an RDS\_INSTANCE target that is part of a DB Cluster |
| <a name="output_proxy_target_type"></a> [proxy\_target\_type](#output\_proxy\_target\_type) | Type of target. e.g. `RDS_INSTANCE` or `TRACKED_CLUSTER` |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group ID of the cluster |
<!-- END_TF_DOCS -->