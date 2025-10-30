resource "aws_s3_bucket" "bigdata_youtube_cleansed" {
  bucket        = "bigdata-youtube-cleansed-${random_id.suffix.hex}"
  force_destroy = true
  
  tags = {
    "youtube" = "true"
  }
}

resource "aws_s3_bucket_versioning" "bigdata_youtube_cleansed_versioning" {
  bucket = aws_s3_bucket.bigdata_youtube_cleansed.id
  versioning_configuration {
    status = "Enabled"
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
          aws_s3_bucket.bigdata_youtube_cleansed.arn,
          "${aws_s3_bucket.bigdata_youtube_cleansed.arn}/*",
          "arn:aws:s3:::projectyoutubedata-${random_id.suffix.hex}",  
          "arn:aws:s3:::projectyoutubedata-${random_id.suffix.hex}/*",
          "arn:aws:s3:::projectyoutubedataanalytics-${random_id.suffix.hex}",
          "arn:aws:s3:::projectyoutubedataanalytics-${random_id.suffix.hex}/*"
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
          "${aws_s3_bucket.bigdata_youtube_cleansed.arn}/*",
          "arn:aws:s3:::projectyoutubedata-${random_id.suffix.hex}/*"  
        ]
      }
    ]
  })
}
resource "aws_s3_object" "raw_statistics_folder" {
  bucket = aws_s3_bucket.bigdata_youtube_cleansed.bucket
  key    = "projectyoutubedata/raw_statistics/.keep"

  depends_on = [aws_s3_bucket.bigdata_youtube_cleansed]
}

