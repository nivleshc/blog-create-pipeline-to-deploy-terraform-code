resource "aws_kms_key" "key" {
  description = "This key will be used to encrypt the Amazon S3 bucket objects"
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.s3_bucket_name}-${var.env}"
  target_key_id = aws_kms_key.key.id
}

resource "aws_s3_bucket" "s3bucket" {
  bucket = var.s3_bucket_name

  versioning {
    enabled = true
  }

  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "blockall" {
  bucket = aws_s3_bucket.s3bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-lock-table" {
  name         = var.dynamodb_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}