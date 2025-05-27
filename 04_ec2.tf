# ==============================================================================
# EC2 Instance Configuration
# ==============================================================================

# Security Group for EC2 Instance
resource "aws_security_group" "ec2_private" {
  name_prefix = "${var.project_name}-ec2-"
  description = "Security group for EC2 instance in private subnet"
  vpc_id      = aws_vpc.main.id

  # Session Manager経由でアクセスするため、インバウンドルールは不要
  # VPCエンドポイントへのHTTPS通信を許可
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS to VPC endpoints"
  }

  # DNS解決のためのアウトバウンド通信
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "DNS TCP queries"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "DNS UDP queries"
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# User Data Script for EC2 Instance
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region   = var.aws_region
    project_name = var.project_name
  }))
}

# EC2 Instance
resource "aws_instance" "bedrock_private" {
  ami                     = data.aws_ami.amazon_linux.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private.id
  vpc_security_group_ids  = [aws_security_group.ec2_private.id]
  iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name
  user_data               = local.user_data

  # EBSボリューム設定
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
    
    tags = {
      Name = "${var.project_name}-root-volume"
      Project = var.project_name
    }
  }

  # インスタンス停止時の保護
  disable_api_stop        = false
  disable_api_termination = false

  tags = {
    Name = "${var.project_name}-private-instance"
    Type = "Private"
    Project = var.project_name
    Purpose = "Bedrock VPC Endpoint Testing"
  }

  # VPCエンドポイントが作成されてからインスタンスを起動
  depends_on = [
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssm_messages,
    aws_vpc_endpoint.ec2_messages,
    aws_vpc_endpoint.bedrock_runtime,
    aws_vpc_endpoint.bedrock
  ]
}

# Output EC2 Information
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.bedrock_private.id
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.bedrock_private.private_ip
}

output "ec2_security_group_id" {
  description = "Security Group ID for EC2 instance"
  value       = aws_security_group.ec2_private.id
}

output "connection_instructions" {
  description = "Instructions for connecting to the instance"
  value = <<-EOF
    🔗 EC2インスタンスへの接続方法:
    
    1. AWSコンソールにアクセス
    2. EC2サービスを選択
    3. インスタンス ID: ${aws_instance.bedrock_private.id} を選択
    4. 「接続」ボタン → 「Session Manager」タブを選択
    5. 「接続」をクリック
    
    🧪 Bedrockテスト方法:
    接続後、以下のコマンドを実行:
    
    Python版テスト:
    python3 /home/ec2-user/test_bedrock.py
    
    AWS CLI版テスト:
    bash /home/ec2-user/test_aws_cli.sh
    
    📋 手動テスト:
    aws bedrock list-foundation-models --region ${var.aws_region}
    
    🌐 VPC Endpoint DNS:
    Bedrock Runtime: ${aws_vpc_endpoint.bedrock_runtime.dns_entry[0].dns_name}
  EOF
}