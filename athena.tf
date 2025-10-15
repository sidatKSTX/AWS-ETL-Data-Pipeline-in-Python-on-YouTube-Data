# 1. Create an S3 bucket
resource "aws_s3_bucket" "aws_temp_files" {
  bucket = "aws-temp-files-123456"
}

# 2. Create an S3 folder (prefix) inside the bucket
resource "aws_s3_object" "aws_athena_folder" {
  bucket = aws_s3_bucket.aws_temp_files.id
  key    = "aws_athena/"
}

# 3. Set up an S3 bucket policy to allow Athena to write query results
resource "aws_s3_bucket_policy" "athena_s3_policy" {
  bucket = aws_s3_bucket.aws_temp_files.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "athena.amazonaws.com"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
            "arn:aws:s3:::aws-temp-files-123456",
            "arn:aws:s3:::aws-temp-files-123456/*"
        ]
      }
    ]
  })
}

# 4. Configure Athena Workgroup to use the S3 bucket for query results
resource "aws_athena_workgroup" "aws_athena_workgroup" {
  name = "aws_athena_workgroup"

  configuration {
    result_configuration {
      output_location = "s3://aws-temp-files-123456/aws_athena/"
    }
  }
}
