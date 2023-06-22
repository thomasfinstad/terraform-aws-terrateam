# Example

This examples showcases some of the requirements, but is not a recommendation for best-practices.

Some manual steps are still required before terrateam will work, all of which is in the official terrateam documentation.

- Set up the GitHub App.
- Create an AWS Secrets Manager secret with the information for the github app.
- Install the GitHub App to the repository you want to work with.
- Create the OICD identity provider in AWS and a role to go with it.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_prerequisites"></a> [prerequisites](#module\_prerequisites) | ./prerequisites | n/a |
| <a name="module_terrateam"></a> [terrateam](#module\_terrateam) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.alb_egress_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_egress_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_egress_secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_ingress_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.rds_ingress_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_secretsmanager_secret.github_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Terrateam ALB endpoint for github webhook url |
| <a name="output_prerequsities"></a> [prerequsities](#output\_prerequsities) | Prereq info |
| <a name="output_terrateam"></a> [terrateam](#output\_terrateam) | Terrateam info |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
