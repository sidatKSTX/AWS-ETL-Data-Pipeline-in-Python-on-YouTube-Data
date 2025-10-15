
resource "aws_iam_role" "bigdata_youtube_role" {
  name = "bigdata-youtube-role-1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Purpose = "youtube"
    Service = "glue"
  }
}

resource "aws_iam_policy" "bigdata_youtube_policy" {
  name        = "bigdata-youtube-policy-1"
  description = "IAM policy for Glue to read and list S3 bucket projectyoutubedata"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::projectyoutubedata",
        "arn:aws:s3:::projectyoutubedata/*",
        "arn:aws:s3:::bigdata-youtube-cleansed",
        "arn:aws:s3:::bigdata-youtube-cleansed/*",
        "arn:aws:s3:::bigdata-youtube-assets-unique-1234",
        "arn:aws:s3:::bigdata-youtube-assets-unique-1234/*",
        "arn:aws:s3:::projectyoutubedataanalytics",
        "arn:aws:s3:::projectyoutubedataanalytics/*"

      ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "glue_role_attachment" {
  role       = aws_iam_role.bigdata_youtube_role.name
  policy_arn = aws_iam_policy.bigdata_youtube_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.bigdata_youtube_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_catalog_database" "db_youtube_raw" {
  name = "db_youtube_raw"
}


resource "aws_glue_crawler" "bigdata_youtube_glue_crawler" {
  name          = "bigdata-youtube-glue-crawler"
  role          = aws_iam_role.bigdata_youtube_role.arn
  database_name = aws_glue_catalog_database.db_youtube_raw.name

  s3_target {
    path = "s3://projectyoutubedata/raw_statistics_reference_data/"
  }

  tags = {
    Purpose = "youtube"
    Service = "glue"
  }
}
resource "aws_glue_crawler" "bigdata_youtube_glue_crawler2" {
  name          = "bigdata-youtube-glue-csvcrawler2"
  role          = aws_iam_role.bigdata_youtube_role.arn
  database_name = aws_glue_catalog_database.db_youtube_raw.name

  s3_target {
    path = "s3://projectyoutubedata/raw_statistics/"
  }

  tags = {
    Purpose = "youtube"
    Service = "glue"
  }
}

resource "aws_glue_trigger" "crawler_trigger" {
  name = "trigger-bigdata-youtube-crawler"
  type = "ON_DEMAND"  # This will allow you to manually trigger the crawler

  actions {
    crawler_name = aws_glue_crawler.bigdata_youtube_glue_crawler.name
  }

  depends_on = [
    aws_glue_crawler.bigdata_youtube_glue_crawler
  ]
}
resource "aws_glue_trigger" "crawler_trigger_2" {
  name = "trigger-bigdata-youtube-crawler-2"
  type = "ON_DEMAND"

  actions {
    crawler_name = aws_glue_crawler.bigdata_youtube_glue_crawler2.name
  }

  depends_on = [aws_glue_crawler.bigdata_youtube_glue_crawler2]
}
resource "aws_glue_catalog_database" "db_youtube_cleansed" {
  name = "db-youtube-cleansed"
}

resource "aws_glue_crawler" "bigdata_youtube_cleansed_glue_crawler3" {
  name          = "bigdata_youtube_cleansed_glue_crawler3"
  role          = aws_iam_role.bigdata_youtube_role.arn
  database_name = aws_glue_catalog_database.db_youtube_cleansed.name

  s3_target {
    path = "s3://bigdata-youtube-cleansed/projectyoutubedata/raw_statistics/"
  }

  tags = {
    Purpose = "youtube"
    Service = "glue"
  }
}
resource "aws_glue_trigger" "crawler_trigger_3" {
  name = "trigger-bigdata-youtube-crawler-3"
  type = "ON_DEMAND"

  actions {
    crawler_name = aws_glue_crawler.bigdata_youtube_cleansed_glue_crawler3.name
  }

  depends_on = [aws_glue_crawler.bigdata_youtube_cleansed_glue_crawler3]
}
