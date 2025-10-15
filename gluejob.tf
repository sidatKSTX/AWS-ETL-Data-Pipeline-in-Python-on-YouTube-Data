# Creating the assets bucket
resource "aws_s3_bucket" "assestsdata" {
  bucket = "bigdata-youtube-assets-unique-1234"
}

# Enabling versioning on the assets bucket
resource "aws_s3_bucket_versioning" "bigdata_youtube_assets_versioning" {
  bucket = aws_s3_bucket.assestsdata.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Creating folder structure within the S3 bucket
resource "aws_s3_object" "aws_services_folder" {
  bucket = aws_s3_bucket.assestsdata.bucket
  key    = "aws_services/"  # This represents the folder in S3
  acl    = "private"
  content = ""
}

resource "aws_s3_object" "aws_glue_folder" {
  bucket = aws_s3_bucket.assestsdata.bucket
  key    = "aws_services/aws_glue/"  # Folder inside the aws_services folder
  acl    = "private"
  content = ""
}



resource "aws_s3_object" "etl_jobs_folder" {
  bucket = aws_s3_bucket.assestsdata.bucket
  key    = "aws_services/aws_glue/etl_jobs/"  # Folder inside the aws_glue folder
  acl    = "private"
  content = ""
}

resource "aws_s3_object" "etl_jobs_folder1" {
  bucket = aws_s3_bucket.assestsdata.bucket
  key    = "aws_services/aws_glue/etl_jobs1/"  # Folder inside the aws_glue folder
  acl    = "private"
  content = ""
}

# Uploading the Glue script file to S3
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.assestsdata.bucket
  key    = "aws_services/aws_glue/etl_jobs/bigdata-youtube-json-parquet.py"  # Script file path
  acl    = "private"
  content = <<EOF
# Your Python script content goes here
# Example content
import sys
import boto3
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Add your script logic here
EOF
}

# Creating Glue job that uses the script file
resource "aws_glue_job" "bigdata_youtube_spark_convert_csv_parquet" {
  name     = "bigdata-youtube-spark-convert-csv-parquet"
  role_arn = aws_iam_role.bigdata_youtube_role.arn  # Correcting the argument to 'role_arn'

  command {
    name            = "glueetl"
    script_location = "s3://bigdata-youtube-assets-unique-1234/aws_services/aws_glue/etl_jobs/bigdata-youtube-csv-parquet.py"  # Script filename included here
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir" = "s3://bigdata-youtube-assets-unique-1234/aws_services/aws_glue/etl_jobs/"
  }

  max_capacity = 10  # Adjust based on your job requirements
  timeout      = 60  # Timeout in minutes

  tags = {
    Purpose = "youtube"
    Service = "glue"
  }
}
