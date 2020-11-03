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

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags                 = local.tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id     = aws_vpc.main_vpc.id
  tags       = local.tags
  depends_on = [aws_vpc.main_vpc]
}

resource "aws_subnet" "public" {
  count                   = local.count
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true
  tags                    = local.tags
  depends_on              = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = local.tags

}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  depends_on             = [aws_internet_gateway.gw]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "public" {
  count          = local.count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
  lifecycle {
    ignore_changes        = [subnet_id, route_table_id]
    create_before_destroy = true
  }
}

resource "aws_subnet" "private" {
  count                   = local.count
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false
  tags                    = local.tags
  depends_on              = [aws_nat_gateway.nat_gw]
}

resource "aws_eip" "nat_eip" {
  count = local.count
  vpc   = true
  tags  = local.tags
}

resource "aws_nat_gateway" "nat_gw" {
  count         = local.count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = local.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [subnet_id, tags]
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = local.tags
}

resource "aws_route" "private" {
  count                  = local.count
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
  depends_on             = [aws_nat_gateway.nat_gw]
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [route_table_id, nat_gateway_id]
  }
}

resource "aws_route_table_association" "private" {
  count          = local.count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [subnet_id]
  }
}


resource "aws_security_group" "public_sg" {
  name        = "kubernetes_sg_public"
  description = "kubernetes public security group"
  vpc_id      = aws_vpc.main_vpc.id
  dynamic "ingress" {
    iterator = port
    for_each = var.public_ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    iterator = port
    for_each = var.public_egress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = local.tags
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "private_sg" {
  name        = "kubernetes_sg_private"
  description = "kubernetes private security group"
  vpc_id      = aws_vpc.main_vpc.id
  dynamic "ingress" {
    iterator = port
    for_each = var.private_ingress_ports
    content {
      from_port       = port.value
      to_port         = port.value
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [aws_security_group.public_sg.id]
    }
  }
  dynamic "egress" {
    iterator = port
    for_each = var.private_egress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags       = local.tags
  depends_on = [aws_security_group.public_sg]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "bastionHost" {
  ami                    = data.aws_ami.ubuntu.id
  availability_zone      = data.aws_availability_zones.az.names[0]
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  subnet_id              = aws_subnet.public[0].id
  tags                   = merge(map("Bastion", "True"), local.tags)
  lifecycle {
    ignore_changes = [tags]
  }

}

resource "aws_eip" "bastion_eip" {
  vpc  = true
  tags = local.tags
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastionHost.id
  allocation_id = aws_eip.bastion_eip.id
}


