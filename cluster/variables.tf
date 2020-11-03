variable "env" {
  type        = string
  description = "environment"
  default     = "dev"
}

variable "az_count_env" {
  type        = map(number)
  description = "count of azs depending upon the env "
  default = {
    dev  = 1
    prod = 3
  }
}
variable "master_count" {
  type    = number
  default = 1
}
variable "worker_count" {
  type    = number
  default = 2
}

variable "master_instance_type" {
  type    = string
  default = "t3.small"
}

variable "worker_instance_type" {
  type    = string
  default = "t3.small"
}

variable "instance_type_env" {
  type = map(object(
    {
      worker_instance_type = string
      master_instance_type = string
    }
  ))
  description = "instance type depending upon env"
  default = {
    dev = {
      master_instance_type = "t3.small"
      worker_instance_type = "t3.small"
    }
    prod = {
      master_instance_type = "t3.small"
      worker_instance_type = "t3.small"
    }
  }
}

variable "instance_count_env" {
  type = map(object(
    {
      worker_instance_count = number
      master_instance_count = number
    }
  ))
  description = "instance count depending upon env"
  default = {
    dev = {
      master_instance_count = 1
      worker_instance_count = 2
    }
    prod = {
      master_instance_count = 3
      worker_instance_count = 5
    }
  }
}

variable "master_ami" {
  type    = string
  default = "ami-0ec1e7862235fca6a"
}

variable "worker_ami" {
  type    = string
  default = "ami-098bdd9f2707f3e7a"
}

variable "master_iam_role" {
  type    = string
  default = "a2r-kube-masternode-iamrole"
}

variable "worker_iam_role" {
  type    = string
  default = "a2r-kube-workernode-iamrole"
}

variable "key_name" {
  type    = string
  default = "frankfurt-keypair-root"
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
  default     = terraform.workspace
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

variable "nfs" {
  type        = bool
  description = "is nfs required ot not"
  default     = false
}

variable "nfs_ami" {
  type        = string
  description = "nfs ami"
  default     = ""
}
#Variables from the output of vpc

variable "private_sg_id" {
}

variable "private_subnet_id" {
}

variable "public_sg_id" {
}

variable "public_subnet_id" {
}
