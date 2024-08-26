#-----------------------------------
# Password Generator Project
# Created by Maor Brantz
#-----------------------------------

# Providers
provider "aws" {
  region = var.Region
  profile = var.Profile
}

#--------------- VPC ---------------

# Create VPC
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Password Generator VPC - ${var.Environment}"
  }
}

# Create Internet Gateway and Automatically Attach
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "Password Generator IGW"
  }
}

# Create Public Subnet in AZ's A, B
resource "aws_subnet" "Public_A" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.Public_A_CIDR
  availability_zone = "${var.Region}a"
  # Enable Auto-assigned IPv4
  map_public_ip_on_launch = true
  tags = {
    Name                     = "Public Subnet A - ${var.Environment}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "Public_B" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.Public_B_CIDR
  availability_zone = "${var.Region}b"
  # Enable Auto-assigned IPv4
  map_public_ip_on_launch = true
  tags = {
    Name                     = "Public Subnet B - ${var.Environment}"
    "kubernetes.io/role/elb" = 1
  }
}

# Create Route Tables for Public Subnet A
resource "aws_route_table" "Public_RouteTable_A" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = var.VPC_CIDR
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "Public RouteTable A - ${var.Environment}"
  }
}

# Create Route Tables for Public Subnet B
resource "aws_route_table" "Public_RouteTable_B" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = var.VPC_CIDR
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "Public RouteTable B - ${var.Environment}"
  }
}

# Attach Public Subnets to Route Tables A,B
resource "aws_route_table_association" "RouteTable_Attach_A" {
  subnet_id      = aws_subnet.Public_A.id
  route_table_id = aws_route_table.Public_RouteTable_A.id
}

resource "aws_route_table_association" "RouteTable_Attach_B" {
  subnet_id      = aws_subnet.Public_B.id
  route_table_id = aws_route_table.Public_RouteTable_B.id
}

# Create 2 Private Subnets in different Availability Zones: A, B
resource "aws_subnet" "Private_A" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.Private_A_CIDR
  availability_zone = "${var.Region}a"

  tags = {
    Name = "Private Subnet A - ${var.Environment}"
  }
}

resource "aws_subnet" "Private_B" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.Private_B_CIDR
  availability_zone = "${var.Region}b"

  tags = {
    Name = "Private Subnet B - ${var.Environment}"
  }
}

# Create Private Route Tabless for Availability zones: A, B
resource "aws_route_table" "Private_Route_Table_A" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  }
  route {
    cidr_block = var.VPC_CIDR
    gateway_id = "local"
  }
  tags = {
    Name = "Route Table Private Subnet A - ${var.Environment}"
  }
}

resource "aws_route_table" "Private_Route_Table_B" {
  vpc_id = aws_vpc.VPC.id
   route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  }
  route {
    cidr_block = var.VPC_CIDR
    gateway_id = "local"
  }
  tags = {
    Name = "Route Table Private Subnet B - ${var.Environment}"
  }
}

# Elastic IP for NAT
resource "aws_eip" "NAT_EIP" {
  domain = "vpc"
  tags = {
    Name = "Elastic IP - ${var.Environment}"
  }
}

# NAT Gateway (In AZ-A)
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.Public_A.id
  tags = {
    Name = "NAT Gateway - ${var.Environment}"
  }
}

# Attach Private Subnet A to Route Table
resource "aws_route_table_association" "Route_Table_Private_A" {
  subnet_id      = aws_subnet.Private_A.id
  route_table_id = aws_route_table.Private_Route_Table_A.id
}

# Attach Private Subnet B to Route Table
resource "aws_route_table_association" "Route_Table_Private_B" {
  subnet_id      = aws_subnet.Private_B.id
  route_table_id = aws_route_table.Private_Route_Table_B.id
}

#---------------EKS---------------

# IAM Role for EKS
resource "aws_iam_role" "EKS_Role" {
  name = "EKS_Cluster_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Add Policy to IAM Role for EKS
resource "aws_iam_role_policy_attachment" "EKS_Cluster_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role     = aws_iam_role.EKS_Role.name
}

# Create EKS Cluster
resource "aws_eks_cluster" "Cluster" {
  name     = var.Cluster_Name
  role_arn  = aws_iam_role.EKS_Role.arn

  vpc_config {
    subnet_ids = [aws_subnet.Public_A.id, aws_subnet.Public_B.id, aws_subnet.Private_A.id, aws_subnet.Private_B.id]
    }

  depends_on = [
    aws_iam_role_policy_attachment.EKS_Cluster_Policy
  ]
}

# IAM Role for Nodes
resource "aws_iam_role" "Node_Role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Add Policy to IAM Role for Nodes
resource "aws_iam_role_policy_attachment" "Node_Role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role     = aws_iam_role.Node_Role.name
}

resource "aws_iam_role_policy_attachment" "Node_Role-AmazonEKSCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role     = aws_iam_role.Node_Role.name
}

resource "aws_iam_role_policy_attachment" "Node_Role-AmazonEC2ContainerRegistryReadOnlyy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role     = aws_iam_role.Node_Role.name
}

resource "aws_iam_role_policy_attachment" "Node_Role-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role     = aws_iam_role.Node_Role.name
}

# Create Node Group
resource "aws_eks_node_group" "Worker_Nodes_Group" {
  cluster_name    = aws_eks_cluster.Cluster.name
  node_group_name = "Worker_Nodes_Group"
  node_role_arn   = aws_iam_role.Node_Role.arn
  subnet_ids      = [aws_subnet.Private_A.id, aws_subnet.Private_B.id]

  scaling_config {
    desired_size = var.Scaling-Desired_Nodes
    max_size     = var.Scaling-Max_Nodes
    min_size     = var.Scaling-Desired_Nodes
  }

  launch_template {
    name    = aws_launch_template.EKS_Node_Template.name
    version = aws_launch_template.EKS_Node_Template.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.Node_Role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.Node_Role-AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.Node_Role-AmazonEC2ContainerRegistryReadOnlyy,
  ]
}

# Launch Template for EKS Nodes
resource "aws_launch_template" "EKS_Node_Template" {
  name          = var.EKS_Template_Name
  instance_type = var.Instance_type
}
