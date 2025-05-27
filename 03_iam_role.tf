# ==============================================================================
# IAM Role Configuration
# ==============================================================================

# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_bedrock_role" {
  name        = "${var.project_name}-ec2-role"
  description = "IAM role for EC2 instance to access Amazon Bedrock"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Condition = {}
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
    Project = var.project_name
  }
}

# Custom IAM Policy for Bedrock Access
resource "aws_iam_policy" "bedrock_access" {
  name        = "${var.project_name}-bedrock-access"
  description = "Policy for accessing Amazon Bedrock services"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-bedrock-policy"
    Project = var.project_name
  }
}

# Custom IAM Policy for VPC Endpoint Access
resource "aws_iam_policy" "vpc_endpoint_access" {
  name        = "${var.project_name}-vpc-endpoint-access"
  description = "Policy for accessing services via VPC endpoints"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-vpc-endpoint-policy"
    Project = var.project_name
  }
}

# Attach AWS Managed Policy for SSM (Session Manager)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_bedrock_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach Custom Bedrock Policy
resource "aws_iam_role_policy_attachment" "bedrock_access" {
  role       = aws_iam_role.ec2_bedrock_role.name
  policy_arn = aws_iam_policy.bedrock_access.arn
}

# Attach Custom VPC Endpoint Policy
resource "aws_iam_role_policy_attachment" "vpc_endpoint_access" {
  role       = aws_iam_role.ec2_bedrock_role.name
  policy_arn = aws_iam_policy.vpc_endpoint_access.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_bedrock_role.name

  tags = {
    Name = "${var.project_name}-ec2-profile"
    Project = var.project_name
  }
}

# Output IAM Role Information
output "iam_role_arn" {
  description = "ARN of the IAM role for EC2"
  value       = aws_iam_role.ec2_bedrock_role.arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "iam_policies" {
  description = "List of attached IAM policies"
  value = {
    bedrock_access_policy_arn     = aws_iam_policy.bedrock_access.arn
    vpc_endpoint_access_policy_arn = aws_iam_policy.vpc_endpoint_access.arn
    ssm_managed_policy_arn        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}