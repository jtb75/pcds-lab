variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "protected_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-protected-s3-bucket-004"
}

variable "private_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-private-s3-bucket-004"
}

variable "public_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-public-s3-bucket-004"
}

