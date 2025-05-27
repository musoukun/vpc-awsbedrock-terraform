# ==============================================================================
# VPC Configuration
# ==============================================================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# Internet Gateway (作成するが使用しない - プライベート環境のため)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
    Project = var.project_name
    Note = "Created but not used for private-only environment"
  }
}

# Default Security Group (デフォルトSGの設定)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # すべてのインバウンドトラフィックを拒否
  ingress = []

  # すべてのアウトバウンドトラフィックを拒否
  egress = []

  tags = {
    Name = "${var.project_name}-default-sg"
    Project = var.project_name
  }
}