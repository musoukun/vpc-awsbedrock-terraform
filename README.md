# Amazon Bedrock VPC Endpoint Infrastructure

このTerraformプロジェクトは、Amazon BedrockをVPCエンドポイント経由でプライベートにアクセスできる環境を構築します。

## 🔒 **セキュリティ重要事項**

⚠️ **このプロジェクトをGitHubにアップロードする前に必ず以下を確認してください：**

### **機密情報の管理**
- **AWSアカウントID**、**アクセスキー**、**シークレットキー**などの機密情報は環境変数で管理
- `.env`ファイルには実際の値を設定（`.gitignore`で除外済み）
- `terraform.tfvars`には機密情報を記載しない
- `.env.example`をテンプレートとして使用

### **GitHubにアップロード禁止のファイル**
- `.env` （実際の環境変数ファイル）
- `terraform.tfstate*` （Terraformの状態ファイル）
- `.terraform/` （Terraformキャッシュ）
- AWSアクセスキーを含むファイル
- 実際のAWSアカウントIDを含むファイル

## 📁 **ファイル構成**

```
D:\Terraform\
├── main.tf                 # メイン設定とプロバイダー
├── variables.tf            # 変数定義（環境変数対応）
├── terraform.tfvars        # 安全な設定値のみ
├── .env.example            # 環境変数テンプレート
├── .gitignore              # Git除外設定
├── 01_vpc.tf              # VPC関連リソース
├── 02_private_subnet.tf   # プライベートサブネット・VPCエンドポイント
├── 03_iam_role.tf         # IAMロール・ポリシー
├── 04_ec2.tf              # EC2インスタンス
├── user_data.sh           # EC2セットアップスクリプト
├── outputs.tf             # 出力値定義
└── README.md              # このファイル
```

## 🚀 **セットアップ手順**

### **1. 必要な環境変数の設定**

#### **Step 1: 環境変数ファイルの作成**

```bash
# テンプレートをコピー
cp .env.example .env

# または手動で.envファイルを作成
```

#### **Step 2: 実際の値を設定**

`.env`ファイルを編集し、以下の値を設定：

```bash
# AWS設定（⚠️ 必須）
AWS_REGION=ap-northeast-1
AWS_ACCOUNT_ID=123456789012  # ← あなたの実際のAWSアカウントID

# AWS認証（いずれか一つ）
AWS_PROFILE=your-sso-profile-name  # SSO使用の場合
# または
# AWS_ACCESS_KEY_ID=AKIA...        # アクセスキー使用の場合
# AWS_SECRET_ACCESS_KEY=...

# プロジェクト設定（オプション）
PROJECT_NAME=bedrock-vpc-endpoint
VPC_CIDR=10.0.0.0/16
PRIVATE_SUBNET_CIDR=10.0.1.0/24
AVAILABILITY_ZONE=ap-northeast-1a
INSTANCE_TYPE=t3.micro
```

#### **Step 3: 環境変数の読み込み**

**WSL/Linux/macOSの場合：**
```bash
# 環境変数を読み込み
source .env

# 確認
echo $AWS_ACCOUNT_ID
echo $AWS_REGION
```

**Windows PowerShellの場合：**
```powershell
# 環境変数を設定
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}

# 確認
$env:AWS_ACCOUNT_ID
$env:AWS_REGION
```

### **2. AWS認証の設定**

#### **方法A: SSO認証（推奨）**
```bash
aws configure sso
# 設定後、プロファイル名を環境変数に設定
export AWS_PROFILE=your-profile-name
```

#### **方法B: IAMユーザー認証**
```bash
aws configure
# アクセスキーとシークレットキーを設定
```

### **3. Bedrockモデルアクセス申請**

⚠️ **実行前に必須の設定**

1. **AWSコンソール** → **Amazon Bedrock** にアクセス
2. **Model access** → **Request access** をクリック
3. 以下のモデルへのアクセスを申請：
   - ✅ **Amazon Titan Text G1 - Express**
   - ✅ **Amazon Titan Embeddings G1 - Text**
   - ✅ **Anthropic Claude 3.5 Sonnet** （オプション）
4. **Request access** → 承認を待つ（通常数分〜1時間）

### **4. Terraform実行**

```bash
# ディレクトリ移動
cd D:\Terraform

# 環境変数確認
echo $AWS_ACCOUNT_ID  # 値が表示されることを確認

# Terraform初期化
terraform init

# プラン確認
terraform plan

# 実行
terraform apply
```

## 🧪 **テスト実行**

### **1. EC2への接続**

Terraform実行後、出力される接続方法に従って：

1. **AWSコンソール** → **EC2** → **インスタンス**
2. インスタンスを選択 → **「接続」** → **「Session Manager」**
3. **「接続」**をクリック

### **2. Bedrockテスト**

EC2に接続後、以下のテストを実行：

```bash
# 包括テスト（推奨）
python3 /home/ec2-user/test_bedrock.py

# AWS CLIテスト
bash /home/ec2-user/test_aws_cli.sh

# 手動テスト
aws sts get-caller-identity
aws bedrock list-foundation-models --region ap-northeast-1
```

## 💰 **コスト情報**

### **月額概算（東京リージョン）**
- **EC2 t3.micro**: 無料枠（月750時間）
- **VPCエンドポイント**: 約$36/月（5エンドポイント × $0.01/時間）
- **EBS 30GB**: 無料枠
- **Bedrock利用**: 使用量に依存（テスト程度なら数ドル）

### **コスト最適化**
```bash
# 使用後は必ずリソースを削除
terraform destroy
```

## 🔍 **トラブルシューティング**

### **環境変数エラー**
```bash
# 環境変数が設定されているか確認
env | grep AWS

# 再設定
source .env
```

### **認証エラー**
```bash
# AWS認証確認
aws sts get-caller-identity

# プロファイル確認
aws configure list
```

### **Bedrockアクセスエラー**
```
❌ Model access denied
```
**解決方法**: AWSコンソールでBedrockモデルアクセス申請を確認

## 📋 **環境変数リファレンス**

### **必須環境変数**
| 変数名 | 説明 | 例 |
|--------|------|-----|
| `AWS_REGION` | AWSリージョン | `ap-northeast-1` |
| `AWS_ACCOUNT_ID` | AWSアカウントID | `123456789012` |
| `AWS_PROFILE` | AWSプロファイル名 | `AdministratorAccess-123456789012` |

### **オプション環境変数**
| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `PROJECT_NAME` | プロジェクト名 | `bedrock-vpc-endpoint` |
| `VPC_CIDR` | VPC CIDR | `10.0.0.0/16` |
| `INSTANCE_TYPE` | EC2インスタンスタイプ | `t3.micro` |

## 🗑️ **クリーンアップ**

```bash
# リソース削除
terraform destroy

# 確認
terraform show
```
