module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "prod"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/cluster/prod" = "owned"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "<18"

  cluster_version = "1.21"
  cluster_name    = "prod"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  # Only need one node
  worker_groups = [
    {
      instance_type = "t3a.medium"
      asg_max_size  = 1
    }
  ]
}
