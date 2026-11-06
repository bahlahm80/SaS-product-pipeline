resource "aws_security_group" "eks_node_sg" {
  name        = "sas-eks-node-sg-${var.environment}"
  description = "Security group for EKS managed worker nodes in ${var.environment}"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sas-eks-node-sg-${var.environment}"
  }
}