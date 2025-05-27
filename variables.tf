# ==============================================================================
# Terraform Variables Configuration (環境変数対応版)
# ==============================================================================

# AWS設定
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_account_id" {
  description = "AWS Account ID for security policies"
  type        = string
  default     = ""
}

# プロジェクト設定
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "bedrock-vpc-endpoint"
}

# ネットワーク設定
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for subnet"
  type        = string
  default     = "ap-northeast-1a"
}

# EC2設定
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# セキュリティ設定
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}

# タグ設定
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# 環境変数からの読み込み
locals {
  # 環境変数が設定されている場合は優先、なければデフォルト値を使用
  aws_region           = var.aws_region != "" ? var.aws_region : (can(regex(".", env("AWS_REGION"))) ? env("AWS_REGION") : "ap-northeast-1")
  aws_account_id       = var.aws_account_id != "" ? var.aws_account_id : (can(regex(".", env("AWS_ACCOUNT_ID"))) ? env("AWS_ACCOUNT_ID") : "")
  project_name         = var.project_name != "" ? var.project_name : (can(regex(".", env("PROJECT_NAME"))) ? env("PROJECT_NAME") : "bedrock-vpc-endpoint")
  vpc_cidr            = var.vpc_cidr != "" ? var.vpc_cidr : (can(regex(".", env("VPC_CIDR"))) ? env("VPC_CIDR") : "10.0.0.0/16")
  private_subnet_cidr = var.private_subnet_cidr != "" ? var.private_subnet_cidr : (can(regex(".", env("PRIVATE_SUBNET_CIDR"))) ? env("PRIVATE_SUBNET_CIDR") : "10.0.1.0/24")
  availability_zone   = var.availability_zone != "" ? var.availability_zone : (can(regex(".", env("AVAILABILITY_ZONE"))) ? env("AVAILABILITY_ZONE") : "ap-northeast-1a")
  instance_type       = var.instance_type != "" ? var.instance_type : (can(regex(".", env("INSTANCE_TYPE"))) ? env("INSTANCE_TYPE") : "t3.micro")
}

# 環境変数の説明
variable "env_var_instructions" {
  description = <<-EOT
    Environment Variables Setup:
    
    Required:
    - AWS_REGION: AWS region (e.g., ap-northeast-1)
    - AWS_ACCOUNT_ID: Your AWS account ID
    
    Optional:
    - PROJECT_NAME: Project name for resources
    - VPC_CIDR: VPC CIDR block
    - PRIVATE_SUBNET_CIDR: Private subnet CIDR
    - AVAILABILITY_ZONE: Availability zone
    - INSTANCE_TYPE: EC2 instance type
    
    Usage:
    export AWS_REGION=ap-northeast-1
    export AWS_ACCOUNT_ID=123456789012
    terraform plan
  EOT
  type        = string
  default     = ""
}