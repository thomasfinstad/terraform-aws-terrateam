locals {
  container_name = "terrateam-server"

  container_env_null_str = { for k, v in {
    "TERRAT_API_BASE" = var.terrateam.api_base

    "DB_PORT" = var.database.port
    "DB_HOST" = var.database.host
    "DB_NAME" = var.database.name
    "DB_USER" = var.database.username
    "DB_PASS" = var.database.password

    "GITHUB_APP_ID"             = var.github.app_id
    "GITHUB_APP_CLIENT_ID"      = var.github.app_client_id
    "GITHUB_APP_CLIENT_SECRET"  = var.github.app_client_secret
    "GITHUB_APP_PEM"            = var.github.app_pem
    "GITHUB_WEBHOOK_SECRET"     = var.github.webhook_secret
    "GITHUB_WEBHOOK_URL_UPDATE" = var.github.webhook_url_update ? "TRUE" : "FALSE"
    } : k => (v == null ? "null" : v) # Makes it easier to debug a bad config when using the module
  }

  container_env = {
    for k, v in local.container_env_null_str :
    k => (
      # If env var is secrets manager ensure it contains all required colons even if json-key, version-stage, or version-id is not provided
      strcontains(v, ":secretsmanager:") ? (
        join(":", slice(split(":", "${v}:::"), 0, 10))
      )
      :
      # If not secrets manager keep original value
      (v)
    )
  }

  # Used for iam policy
  secrets    = [for k, v in local.container_env : join(":", slice(split(":", v), 0, 7)) if strcontains(v, ":secretsmanager:")]
  parameters = [for k, v in local.container_env : v if strcontains(v, ":ssm:")]
  #kms_keys   = [for k, s in data.aws_secretsmanager_secret.environment_secrets : s.kms_key_id]
}

# Causes annoying requirements to `-target` apply before full apply
# data "aws_secretsmanager_secret" "environment_secrets" {
#   for_each = toset(local.secrets)
#   arn      = each.value
# }
