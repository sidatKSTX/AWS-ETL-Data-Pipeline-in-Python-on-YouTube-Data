
resource "aws_s3_bucket" "projectyoutubedataanalytics" {
  bucket        = "projectyoutubedataanalytics-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "youtube_data"
  }
}

resource "aws_s3_bucket_public_access_block" "projectyoutubedataanalytics_pab" {
  bucket = aws_s3_bucket.projectyoutubedataanalytics.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "projectyoutubedataanalytics_versioning" {
  bucket = aws_s3_bucket.projectyoutubedataanalytics.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "projectyoutubedataanalytics_encryption" {
  bucket = aws_s3_bucket.projectyoutubedataanalytics.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_glue_catalog_database" "db_youtube_analytics" {
  name = "db-youtube-analytics-${random_id.suffix.hex}"
}


