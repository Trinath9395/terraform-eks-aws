module "mysql_sg" {
  source = "git::https://github.com/Trinath9395/terraform-aws-sgroup.git?ref=main"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_description = "instaces for mysql"
  sg_name = "mysql"
  project_name = var.project_name
  environment = var.environment
}

module "bastion_sg" {
  source = "git::https://github.com/Trinath9395/terraform-aws-sgroup.git?ref=main"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_description = "bastion instances"
  sg_name = "bastion"
  project_name = var.project_name
  environment = var.environment
}

module "vpn_sg" {
  source = "git::https://github.com/Trinath9395/terraform-aws-sgroup.git?ref=main"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_description = "VPN access for dev teams"
  sg_name = "vpn"
  project_name = var.project_name
  environment = var.environment
}

module "alb_ingress_sg" {
  source = "git::https://github.com/Trinath9395/terraform-aws-sgroup.git?ref=main"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_description = "Created for backend ALB instances"
  sg_name = "alb-ingress"
  project_name = var.project_name
  environment = var.environment
}

module "eks_control_plane_sg" {
  source = "git::https://github.com/Trinath9395/terraform-aws-sgroup.git?ref=main"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_description = "Created for backend ALB instances"
  sg_name = "eks-control-plane"
  project_name = var.project_name
  environment = var.environment
}

module "eks_node_sg" {
  source = "git::https://github.com/Trinath9395/terraform-aws-sgroup.git?ref=main"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_description = "Created for backend ALB instances"
  sg_name = "eks-node"
  project_name = var.project_name
  environment = var.environment
}

resource "aws_security_group_rule" "eks_control_plane_node" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = module.eks_control_plane_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_alb_ingress" {
  type = "ingress"
  from_port = 30000
  to_port = 32767
  protocol = "tcp"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_vpc" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_bastion" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = module.bastion_sg.sg_id 
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "alb_ingress_bastion" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "alb_ingress_bastion_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "alb_ingress_public_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "bastion_public" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id 
}

resource "aws_security_group_rule" "mysql_bastion" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = module.bastion_sg.sg_id 
  security_group_id = module.mysql_sg.sg_id  
}

resource "aws_security_group_rule" "mysql_eks_node" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = module.eks_node_sg.sg_id 
  security_group_id = module.mysql_sg.sg_id  
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_alb_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}
