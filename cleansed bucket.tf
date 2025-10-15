resource "aws_s3_bucket" "bigdata_youtube_cleansed" {
  bucket = "bigdata-youtube-cleansed"
  
  tags = {
    "youtube" = "true"
  }

  versioning {
    enabled = true
  }
}
resource "aws_iam_policy" "bigdata_youtube_read_write_s3_policy" {
  name        = "bigdata-youtube-read-write-s3iampolicy"
  description = "IAM policy for read and write access to specific S3 buckets with tag youtube"
  
  # Policy Document
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Read and List Permissions
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::bigdata-youtube-cleansed",
          "arn:aws:s3:::bigdata-youtube-cleansed/*",
          "arn:aws:s3:::projectyoutubedata",  
          "arn:aws:s3:::projectyoutubedata/*",
          "arn:aws:s3:::projectyoutubedataanalytics",
          "arn:aws:s3:::projectyoutubedataanalytics/*"
        ]
      },
      # Write Permissions: PutObject and DeleteObject
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::bigdata-youtube-cleansed/*",
          "arn:aws:s3:::projectyoutubedata/*"  
        ]
      }
    ]
  })
}
resource "aws_s3_object" "raw_statistics_folder" {
  bucket = "bigdata-youtube-cleansed"
  key    = "projectyoutubedata/raw_statistics/.keep"
  acl    = "private"

  depends_on = [aws_s3_bucket.bigdata_youtube_cleansed]
}

