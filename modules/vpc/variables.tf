variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
  default     = "10.0.0.0/16"
}

variable "az_count_env" {
  type        = map(number)
  description = "count of azs depending upon the env "
  default = {
    dev  = 1
    prod = 3
  }
}

variable "env" {
  type        = string
  description = "environment"
  default     = "dev"
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "private cidr list"
  default     = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "public subnet cidr list"
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "default_tags" {
  #type = map(string)

  default = {
    Managed = "Terraform "
    #Name    = var.cluster_name
  }
}

variable "kubernetes_tags" {
  type    = string
  default = "kubernetes.io/cluster/kubernetes"
}

variable "public_egress_ports" {
  type        = list(number)
  description = "egress ports"
  default     = [0]
}

variable "public_ingress_ports" {
  type        = list(number)
  description = "ingress ports"
  default     = [0]
}

variable "private_egress_ports" {
  type        = list(number)
  description = "egress ports"
  default     = [0]
}

variable "private_ingress_ports" {
  type        = list(number)
  description = "ingress ports"
  default     = [0]
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
  default     = "kubernetes"
}
