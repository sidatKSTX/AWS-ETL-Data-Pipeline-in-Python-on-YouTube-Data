provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "projectyoutubedata" {
  bucket = "projectyoutubedata"
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

# Upload JSON files to raw_statistics_reference_data folder
resource "aws_s3_bucket_object" "json_object" {
  for_each = fileset("C:/Users/bhanu/Documents/terra/Data", "*.json")  # Path to your local JSON files

  # Define the region partition dynamically based on file name (or any logic you want)
  key = "raw_statistics_reference_data/region=${substr(each.value, 0, 2)}/${each.value}"  # Partition by region and raw_statistics_reference_data folder

  bucket = aws_s3_bucket.projectyoutubedata.bucket
  source = "C:/Users/bhanu/Documents/terra/Data/${each.value}"
  acl    = "private"
  server_side_encryption = "AES256"
}

# Upload CSV files to raw_statistics folder
resource "aws_s3_bucket_object" "csv_object" {
  for_each = fileset("C:/Users/bhanu/Documents/terra/Data", "*.csv")  # Path to your local CSV files

  # Define the region partition dynamically based on file name (or any logic you want)
  key = "raw_statistics/region=${substr(each.value, 0, 2)}/${each.value}"  # Partition by region and raw_statistics folder

  bucket = aws_s3_bucket.projectyoutubedata.bucket
  source = "C:/Users/bhanu/Documents/terra/Data/${each.value}"
  acl    = "private"
  server_side_encryption = "AES256"
}
