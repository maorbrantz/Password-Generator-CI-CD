#---------------Main Variables---------------
variable "Region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "Profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "Environment" {
  description = "Environment for the Project"
  type        = string
  default     = "Development"
}

#---------------VPC---------------
variable "VPC_CIDR" {
  type        = string
  description = "My CIDR Block of AWS VPC"
  default     = "10.0.0.0/16"
}

variable "Public_A_CIDR" {
  type        = string
  description = "My CIDR Block for Public A Subnet"
  default     = "10.0.1.0/24"
}

variable "Public_B_CIDR" {
  type        = string
  description = "My CIDR Block for Public B Subnet"
  default     = "10.0.2.0/24"
}

variable "Private_A_CIDR" {
  type        = string
  description = "My CIDR Block for Private Subnet A"
  default     = "10.0.3.0/24"
}

variable "Private_B_CIDR" {
  type        = string
  description = "My CIDR Block for Private Subnet B"
  default     = "10.0.4.0/24"
}


#---------------EKS---------------
variable "Cluster_Name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "Password-Generator-Cluster"
}

# EKS - Nodes Variables
variable "Scaling-Desired_Nodes" {
  description = "Number of Instances in the Node Group"
  type        = string
  default     = "2"

}  

variable "Scaling-Max_Nodes" {
  description = "Maximum Number of Instance in the Node Group"
  type        = string
  default     = "4"
}

# EKS - Nodes Launch Template
variable "Instance_type" {
  description = "Default Instance Type for Nodes"
  type        = string
  default     = "t3.medium"
}

variable "EKS_Template_Name" {
  description = "EKS Template Name for Node Group Nodes"
  type        = string
  default     = "EKS-NG-Template"
}



