variable "cluster_name" {
  description = "Name of EKS Cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
    description = "VPC ID"
    type        = string
}

variable "subnet_id" {
    description = "Subnet IDs"
    type        = list(string)
}

variable "node_group" {
    description = "EKS node group configuration"
    type = map(object({
        instance_types = list(string)
        capacity_type  = string
        scaling_config = object({
          desired_size = number
          max_size     = number
          min_size     = number
        })
    }))
}