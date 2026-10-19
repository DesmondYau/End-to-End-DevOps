terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "proj-terraform-eks-state-bucket"
    key            = "terraform.tf.state"
    region         = "us-east-1"
    dynamodb_table = "proj-terraform-eks-state-locks"
    encrypt        = true
  }
}


provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "./modules/vpc"

    vpc_cidr             = var.vpc_cidr
    private_subnet_cidrs = var.private_subnet_cidrs
    public_subnet_cidrs  = var.public_subnet_cidrs
    availability_zones   = var.availability_zones
    cluster_name         = var.cluster_name
}

module "eks" {
    source = "./modules/eks"

    cluster_name    = var.cluster_name
    cluster_version = var.cluster_version
    vpc_id          = module.vpc.vpc_id
    subnet_id       = module.vpc.private_subnet_ids
    node_group      = var.node_group

}