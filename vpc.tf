resource "aws_security_group" "this" {
  name = var.name
  tags = var.tags

  vpc_id = data.aws_subnet.this.vpc_id
}

data "aws_subnet" "this" {
  id = var.terrateam.subnet_ids[0]
}
