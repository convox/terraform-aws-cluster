terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = "~> 2.22"
  region  = var.region
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.9.0"

  name                 = var.name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 5.1.0"

  cluster_name = var.name
  subnets      = module.vpc.private_subnets

  tags = {
    Name = var.name
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                 = "${var.name}-workers"
      instance_type        = "t3.micro"
      asg_desired_capacity = 2
      autoscale            = true
    },
  ]
}
