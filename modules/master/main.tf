data "aws_availability_zones" "az" {
  state = "available"
}
locals {
  count = lookup(var.az_count_env, var.env, 1)
  tags = merge(map(var.kubernetes_tags, "owned",
  "Name", var.cluster_name), var.default_tags)
}

resource "aws_instance" "master" {
  count                = local.count
  ami                  = var.master_ami
  availability_zone    = data.aws_availability_zones.az.names[count.index]
  instance_type        = var.master_instance_type
  key_name             = var.key_name
  security_groups      = module.vpc.private_sg_ip
  subnet_id            = module.vpc.private_subnet_id[count.index]
  iam_instance_profile = var.master_iam_profile
  tags                 = local.tags
}

resource "aws_instance" "worker" {
  count                = local.count
  ami                  = var.worker_ami
  availability_zone    = data.aws_availability_zones.az.names[count.index]
  instance_type        = var.worker_instance_type
  key_name             = var.key_name
  security_groups      = module.vpc.private_sg_id
  subnet_id            = module.vpc.private_subnet_id[count.index]
  iam_instance_profile = var.worker_iam_profile
  tags                 = local.tags
}

resource "aws_elb" "public_lb" {
  name               = "elb-${var.cluster_name}"
  availability_zones = slice(data.aws_availability_zones.az.names, 0, count)
  security_groups    = module.vpc.public_sg_id
  subnets            = slice(module.vpc.public_subnet_id, 0, count)
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
  tags                      = var.tags
}

resource "aws_elb_attachment" "public_lb_attach" {
  elb      = aws_elb.public_lb.id
  instance = aws_instance.master.*.id
}
