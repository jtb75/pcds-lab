terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }

  required_version = ">= 0.15"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

###########################
# Generate random string
###########################
resource "random_string" "suffix" {
  length = 6
  special = false
}

###########################
# Customer managed KMS key
###########################
resource "aws_kms_key" "kms_s3_key" {
  description             = "Key to protect S3 objects"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
    name          = "alias/s3-key-${random_string.suffix.id}"
    target_key_id = aws_kms_key.kms_s3_key.key_id
}

########################
# Bucket creation
########################
resource "aws_s3_bucket" "my_protected_bucket" {
  bucket = "my-protected-bucket-${random_string.suffix.id}"
  force_destroy = true
}

resource "aws_s3_bucket" "my_private_bucket" {
  bucket = "my-private-bucket-${random_string.suffix.id}"
  force_destroy = true
}

resource "aws_s3_bucket" "my_public_bucket" {
  bucket = "my-public-bucket-${random_string.suffix.id}"
  force_destroy = true
}

##########################
# Bucket private access
##########################
resource "aws_s3_bucket_acl" "my_protected_bucket_acl" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "my_private_bucket_acl" {
  bucket = aws_s3_bucket.my_private_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "my_public_bucket_acl" {
  bucket = aws_s3_bucket.my_public_bucket.id
  acl    = "public-read"
}

#############################
# Enable bucket versioning
#############################
resource "aws_s3_bucket_versioning" "my_protected_bucket_versioning" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "my_private_bucket_versioning" {
  bucket = aws_s3_bucket.my_private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "my_public_bucket_versioning" {
  bucket = aws_s3_bucket.my_public_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

##########################################
# Enable default Server Side Encryption
##########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "my_protected_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.my_protected_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_s3_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
}

########################
# Disabling bucket
# public access
########################
resource "aws_s3_bucket_public_access_block" "my_protected_bucket_access" {
  bucket = aws_s3_bucket.my_protected_bucket.id

  # Block public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

##########################################
# Upload sample data to buckets
##########################################
resource "aws_s3_object" "F11" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  key = "F11.txt"
  source = "objects/ssn.txt"
}

resource "aws_s3_object" "F1" {
  bucket = aws_s3_bucket.my_private_bucket.id
  key = "F1.txt"
  source = "objects/ssn.txt"
  acl = "public-read"
}

resource "aws_s3_object" "WINWORD" {
  bucket = aws_s3_bucket.my_public_bucket.id
  key = "winword.exe"
  source = "objects/wf_sample.exe"
}

