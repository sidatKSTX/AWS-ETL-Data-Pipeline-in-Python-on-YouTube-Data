# Creating Glue assets folder structure in existing analytics bucket
resource "aws_s3_object" "glue_assets_folder" {
  bucket = aws_s3_bucket.projectyoutubedataanalytics.bucket
  key    = "glue-assets/scripts/"
}

# Uploading the Glue script file to S3
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.projectyoutubedataanalytics.bucket
  key    = "glue-assets/scripts/bigdata-youtube-csv-parquet.py"
  source = "bigdata-youtube-csv-parquet.py"
}

# Creating Glue job that uses the script file
resource "aws_glue_job" "bigdata_youtube_spark_convert_csv_parquet" {
  name     = "bigdata-youtube-spark-convert-csv-parquet"
  role_arn = aws_iam_role.bigdata_youtube_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.projectyoutubedataanalytics.bucket}/glue-assets/scripts/bigdata-youtube-csv-parquet.py"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir" = "s3://${aws_s3_bucket.projectyoutubedataanalytics.bucket}/glue-assets/temp/"
  }

  max_capacity = 10
  timeout      = 60

  tags = {
    Purpose = "youtube"
    Service = "glue"
  }
}
