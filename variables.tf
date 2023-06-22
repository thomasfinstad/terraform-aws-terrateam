variable "name" {
  description = "Name of terrateam deployment"
  type        = string
}

variable "tags" {
  description = "Key/Value map of resource tags"
  type        = map(string)
  default     = {}
}

variable "terrateam" {
  description = <<-EOL
    Terrateam Configuration.

    image_url:          Docker image URL e.g. `ghcr.io/terrateamio/terrateam:v1`
    api_base:           Terrateam public-facing URL including a trailing /api e.g. `https://terrateam.example.com/api`
    target_group_arn:   Loadbalancer target group terrateam server will use to receive requests.
    subnet_ids:         Subnets associated with the task or service.
    security_group_ids: Security groups associated with the task or service.
  EOL
  type = object({
    image_url        = optional(string, "ghcr.io/terrateamio/terrateam:v1")
    api_base         = string
    target_group_arn = string
    subnet_ids       = list(string)
  })
}

variable "database" {
  description = <<-EOL
    Database connection configuration

    host:     Cluster endpoint url/ip
    port:     Cluster port
    name:     Database name
    username: Database username
    password: Database password (secret)
  EOL

  type = object({
    host     = string
    port     = string
    name     = string
    username = string
    password = string
  })

  validation {
    condition     = !strcontains(var.database.host, ":")
    error_message = "Colon detected in db host config. Do not include the port in the host, use the dedicated port config parameter."
  }

  validation {
    condition     = startswith(var.database.password, "arn:")
    error_message = "Database password can not be plaintext, use secretsmanager or parameterstore integration format: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar.html"
  }
}

variable "github" {
  description = <<-EOL
    Github integration configuration

    app_id:             Github application id
    app_client_id:      GitHub application client id
    app_client_secret:  GitHub application client secret (secret)
    app_pem:            GitHub application PEM (secret)
    webhook_secret:     GitHub application webhook secret (secret)
    webhook_url_update: Automatically update github application webhook url
  EOL

  type = object({
    app_id             = string
    app_client_id      = string
    app_client_secret  = string
    app_pem            = string
    webhook_secret     = string
    webhook_url_update = optional(bool, true)
  })

  validation {
    condition     = startswith(var.github.app_client_secret, "arn:")
    error_message = "Application client secret can not be plaintext, use secretsmanager or parameterstore integration format: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar.html"
  }

  validation {
    condition     = startswith(var.github.app_pem, "arn:")
    error_message = "Application PEM can not be plaintext, use secretsmanager or parameterstore integration format: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar.html"
  }

  validation {
    condition     = startswith(var.github.webhook_secret, "arn:")
    error_message = "Webhook secret can not be plaintext, use secretsmanager or parameterstore integration format: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar.html"
  }
}
