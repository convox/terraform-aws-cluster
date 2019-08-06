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
      asg_desired_capacity = 2
      asg_min_size         = 1
      asg_max_size         = var.node_max
      autoscale            = true
      instance_type        = "${var.node_type}"
      name                 = "${var.name}-nodes"
    },
  ]

  manage_aws_auth                           = true
  kubeconfig_aws_authenticator_command      = "aws"
  kubeconfig_aws_authenticator_command_args = ["eks", "get-token", "--cluster-name", var.name]
}
