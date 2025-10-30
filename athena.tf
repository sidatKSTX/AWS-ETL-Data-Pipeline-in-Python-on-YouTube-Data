# Create Athena query results folder in existing analytics bucket
resource "aws_s3_object" "athena_results_folder" {
  bucket = aws_s3_bucket.projectyoutubedataanalytics.bucket
  key    = "athena-results/"
}

# Configure Athena Workgroup to use existing analytics bucket
resource "aws_athena_workgroup" "aws_athena_workgroup" {
  name = "aws_athena_workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.projectyoutubedataanalytics.bucket}/athena-results/"
    }
  }
}
