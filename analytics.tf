
resource "aws_s3_bucket" "projectyoutubedataanalytics" {
  bucket = "projectyoutubedataanalytics"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name = "youtube_data"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_glue_catalog_database" "db_youtube_analytics" {
  name = "db_youtube_analytics"
}


