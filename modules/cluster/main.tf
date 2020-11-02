data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  count = lookup(var.az_count_env, var.env, 1)
  tags = merge(map(var.kubernetes_tags, "owned",
  "Name", var.cluster_name), var.default_tags)
}

resource "aws_instance" "master" {
  count                = var.instance_count_env[var.env].master_instance_count
  ami                  = var.master_ami
  availability_zone    = data.aws_availability_zones.az.names[count.index % local.count]
  instance_type        = var.instance_type_env[var.env].master_instance_type
  key_name             = var.key_name
  security_groups      = var.private_sg_id
  subnet_id            = var.private_subnet_id[count.index % local.count]
  iam_instance_profile = var.master_iam_role
  tags                 = local.tags
}

resource "aws_instance" "worker" {
  count                = var.instance_count_env[var.env].worker_instance_count
  ami                  = var.worker_ami
  availability_zone    = data.aws_availability_zones.az.names[count.index % local.count]
  instance_type        = var.instance_type_env[var.env].worker_instance_type
  key_name             = var.key_name
  security_groups      = var.private_sg_id
  subnet_id            = var.private_subnet_id[count.index % local.count]
  iam_instance_profile = var.worker_iam_role
  tags                 = local.tags
}

resource "aws_elb" "public_lb" {
  name = "elb-${var.cluster_name}"
  #availability_zones = slice(data.aws_availability_zones.az.names, 0, local.count)
  subnets         = slice(var.public_subnet_id, 0, local.count)
  security_groups = var.public_sg_id
  listener {
    instance_port     = 6443
    instance_protocol = "http"
    lb_port           = 6443
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }
  cross_zone_load_balancing = true
  connection_draining       = true
  tags                      = local.tags
}

resource "aws_elb_attachment" "public_lb_attach" {
  count    = var.instance_count_env[var.env].master_instance_count
  elb      = aws_elb.public_lb.id
  instance = aws_instance.master[count.index].id
}

