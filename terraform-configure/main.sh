# escolha a região (use us-east-1 pra seguir meu exemplo)
export REGION=us-east-1
export BUCKET=tfstate-ml-sandbox
export TABLE=tfstate-ml-locks

# 1) CRIAR BUCKET (regra especial para us-east-1: NADA de create-bucket-configuration)
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION"

# 2) VERSIONAMENTO
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# 3) CRIPTOGRAFIA
aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]
  }'

# 4) BLOQUEIO DE ACESSO PÚBLICO
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration '{
    "BlockPublicAcls":true,
    "IgnorePublicAcls":true,
    "BlockPublicPolicy":true,
    "RestrictPublicBuckets":true
  }'

# 5) TABELA DE LOCK DO TERRAFORM
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
