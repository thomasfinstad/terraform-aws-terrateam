data "aws_route53_zone" "terrateam" {
  zone_id      = var.route53_zone_id
  private_zone = false
}

resource "aws_route53_record" "loadbalancer" {
  name    = "${var.name}.${trimsuffix(data.aws_route53_zone.terrateam.name, ".")}"
  zone_id = var.route53_zone_id

  type = "A"
  alias {
    name                   = module.loadbalancer.lb_dns_name
    zone_id                = module.loadbalancer.lb_zone_id
    evaluate_target_health = true
  }
}

module "loadbalancer_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = "${var.name}.${trimsuffix(data.aws_route53_zone.terrateam.name, ".")}"
  zone_id     = var.route53_zone_id

  wait_for_validation = true
}

resource "aws_security_group" "loadbalancer" {
  name   = "${var.name}-alb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "lb_ingress_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.loadbalancer.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

module "loadbalancer" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name = var.name

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.loadbalancer.id]

  target_groups = [
    {
      name_prefix      = "tteam-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled           = true
        healthy_threshold = 3
        path              = "/health"

        interval            = 30
        matcher             = "200"
        timeout             = 20
        unhealthy_threshold = 7

        # Easier debugging
        # interval            = 300
        # matcher             = "200-499"
        # timeout             = 120
        # unhealthy_threshold = 10
      }

    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.loadbalancer_certificate.acm_certificate_arn
      target_group_index = 0
    }
  ]
}
