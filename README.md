# terraform-aws-terrateam
Terraform for running Terrateam on AWS ECS

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_execution_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database"></a> [database](#input\_database) | Database connection configuration<br><br>host:     Cluster endpoint url/ip<br>port:     Cluster port<br>name:     Database name<br>username: Database username<br>password: Database password (secret) | <pre>object({<br>    host     = string<br>    port     = string<br>    name     = string<br>    username = string<br>    password = string<br>  })</pre> | n/a | yes |
| <a name="input_github"></a> [github](#input\_github) | Github integration configuration<br><br>app\_id:             Github application id<br>app\_client\_id:      GitHub application client id<br>app\_client\_secret:  GitHub application client secret (secret)<br>app\_pem:            GitHub application PEM (secret)<br>webhook\_secret:     GitHub application webhook secret (secret)<br>webhook\_url\_update: Automatically update github application webhook url | <pre>object({<br>    app_id             = string<br>    app_client_id      = string<br>    app_client_secret  = string<br>    app_pem            = string<br>    webhook_secret     = string<br>    webhook_url_update = optional(bool, true)<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of terrateam deployment | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key/Value map of resource tags | `map(string)` | `{}` | no |
| <a name="input_terrateam"></a> [terrateam](#input\_terrateam) | Terrateam Configuration.<br><br>image\_url:          Docker image URL e.g. `ghcr.io/terrateamio/terrateam:v1`<br>api\_base:           Terrateam public-facing URL including a trailing /api e.g. `https://terrateam.example.com/api`<br>target\_group\_arn:   Loadbalancer target group terrateam server will use to receive requests.<br>subnet\_ids:         Subnets associated with the task or service.<br>security\_group\_ids: Security groups associated with the task or service. | <pre>object({<br>    image_url        = optional(string, "ghcr.io/terrateamio/terrateam:v1")<br>    api_base         = string<br>    target_group_arn = string<br>    subnet_ids       = list(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ECS Service security group id. Usefull for adding non-default access rules |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
