# ==============================================================================
# Outputs Configuration
# ==============================================================================

# VPC関連の出力
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# サブネット関連の出力
output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  value       = aws_subnet.private.cidr_block
}

output "availability_zone" {
  description = "Availability zone of the private subnet"
  value       = aws_subnet.private.availability_zone
}

# VPCエンドポイント関連の出力
output "vpc_endpoints" {
  description = "VPC Endpoint information"
  value = {
    ssm = {
      id       = aws_vpc_endpoint.ssm.id
      dns_name = aws_vpc_endpoint.ssm.dns_entry[0].dns_name
    }
    ssm_messages = {
      id       = aws_vpc_endpoint.ssm_messages.id
      dns_name = aws_vpc_endpoint.ssm_messages.dns_entry[0].dns_name
    }
    ec2_messages = {
      id       = aws_vpc_endpoint.ec2_messages.id
      dns_name = aws_vpc_endpoint.ec2_messages.dns_entry[0].dns_name
    }
    bedrock_runtime = {
      id       = aws_vpc_endpoint.bedrock_runtime.id
      dns_name = aws_vpc_endpoint.bedrock_runtime.dns_entry[0].dns_name
    }
    bedrock = {
      id       = aws_vpc_endpoint.bedrock.id
      dns_name = aws_vpc_endpoint.bedrock.dns_entry[0].dns_name
    }
  }
}

# 全体の接続情報
output "environment_summary" {
  description = "Complete environment summary"
  value = <<-EOF
    🏗️ Amazon Bedrock VPC Endpoint Environment
    ==========================================
    
    📊 Infrastructure Details:
    - Project Name: ${var.project_name}
    - AWS Region: ${var.aws_region}
    - VPC ID: ${aws_vpc.main.id}
    - VPC CIDR: ${aws_vpc.main.cidr_block}
    - Private Subnet ID: ${aws_subnet.private.id}
    - Availability Zone: ${aws_subnet.private.availability_zone}
    
    🖥️ EC2 Instance:
    - Instance ID: ${aws_instance.bedrock_private.id}
    - Instance Type: ${aws_instance.bedrock_private.instance_type}
    - Private IP: ${aws_instance.bedrock_private.private_ip}
    - AMI ID: ${aws_instance.bedrock_private.ami}
    
    🔐 IAM Configuration:
    - Role Name: ${aws_iam_role.ec2_bedrock_role.name}
    - Role ARN: ${aws_iam_role.ec2_bedrock_role.arn}
    - Instance Profile: ${aws_iam_instance_profile.ec2_profile.name}
    
    🌐 VPC Endpoints:
    - SSM: ${aws_vpc_endpoint.ssm.id}
    - SSM Messages: ${aws_vpc_endpoint.ssm_messages.id}
    - EC2 Messages: ${aws_vpc_endpoint.ec2_messages.id}
    - Bedrock: ${aws_vpc_endpoint.bedrock.id}
    - Bedrock Runtime: ${aws_vpc_endpoint.bedrock_runtime.id}
    
    🔗 Connection Instructions:
    1. Go to AWS Console → EC2 → Instances
    2. Select Instance ID: ${aws_instance.bedrock_private.id}
    3. Click "Connect" → "Session Manager" tab
    4. Click "Connect" button
    
    🧪 Testing Commands:
    Once connected via Session Manager:
    
    Python Test:
    python3 /home/ec2-user/test_bedrock.py
    
    AWS CLI Test:
    bash /home/ec2-user/test_aws_cli.sh
    
    Manual Tests:
    aws sts get-caller-identity
    aws bedrock list-foundation-models --region ${var.aws_region}
    
    📋 Notes:
    - All communication is via VPC endpoints (no internet access)
    - Ensure Bedrock model access is requested in AWS Console
    - Check /home/ec2-user/README.txt for detailed instructions
    
    🗑️ Cleanup:
    To destroy all resources: terraform destroy
    
    ==========================================
  EOF
}

# セキュリティ情報
output "security_summary" {
  description = "Security configuration summary"
  value = {
    vpc_private_subnets_only = true
    internet_gateway_attached = true
    internet_access_via_subnets = false
    vpc_endpoints_only = true
    session_manager_access = true
    ssh_key_required = false
    security_groups = {
      ec2_sg = aws_security_group.ec2_private.id
      vpc_endpoint_sg = aws_security_group.vpc_endpoint.id
    }
  }
}
