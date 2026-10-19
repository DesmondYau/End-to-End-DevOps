variable "vpc_cidr" {
  description = "CIDR blocks for VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

##############################################################################

variable "cluster_name" {
  description = "Name of EKS Cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
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