provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "aws_s3_bucket" "projectyoutubedata" {
  bucket        = "projectyoutubedata-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "youtube_data"
  }
}

resource "aws_s3_bucket_public_access_block" "projectyoutubedata_pab" {
  bucket = aws_s3_bucket.projectyoutubedata.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "projectyoutubedata_versioning" {
  bucket = aws_s3_bucket.projectyoutubedata.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "projectyoutubedata_encryption" {
  bucket = aws_s3_bucket.projectyoutubedata.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload JSON files to raw_statistics_reference_data folder
resource "aws_s3_object" "json_object" {
  for_each = fileset("../Data", "*.json")

  key = "raw_statistics_reference_data/region=${substr(each.value, 0, 2)}/${each.value}"
  bucket = aws_s3_bucket.projectyoutubedata.bucket
  source = "../Data/${each.value}"
  server_side_encryption = "AES256"
}

# Upload CSV files to raw_statistics folder
resource "aws_s3_object" "csv_object" {
  for_each = fileset("../Data", "*.csv")

  key = "raw_statistics/region=${substr(each.value, 0, 2)}/${each.value}"
  bucket = aws_s3_bucket.projectyoutubedata.bucket
  source = "../Data/${each.value}"
  server_side_encryption = "AES256"
}
