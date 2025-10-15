
resource "aws_iam_role" "lambda_role" {
  name = "bigdata-youtube-json-parquet-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "bigdata-youtube-lambda-s3-policy"
  description = "Policy for Lambda to read JSON and write Parquet to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Read and Write Permissions
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::bigdata-youtube-cleansed",
          "arn:aws:s3:::bigdata-youtube-cleansed/*",
          "arn:aws:s3:::projectyoutubedata",
          "arn:aws:s3:::projectyoutubedata/*" 
        ]
      },
      # CloudWatch Logging Permissions
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_glue_policy" {
  name        = "bigdata-youtube-lambda-glue-policy"
  description = "Policy for Lambda to interact with AWS Glue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Glue Read and Write Permissions
      {
        Effect   = "Allow"
        Action   = [
          "glue:GetTable",
          "glue:GetTableVersion",
          "glue:GetTableVersions",
          "glue:GetTableDefinition",
          "glue:GetDatabase",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:BatchCreatePartition",
          "glue:BatchUpdatePartition"
        ]
        Resource = [
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:database/db-youtube-cleansed",
          "arn:aws:glue:*:*:table/db-youtube-cleansed/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_glue_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_policy.arn
}

resource "aws_lambda_function" "bigdata_lambda" {
  function_name = "bigdata-youtube-json-parquet-lamda-fn"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"

  filename         = "C:\\Users\\bhanu\\Documents\\lambda_package\\lambda_function.zip" 
  source_code_hash = filebase64sha256("C:\\Users\\bhanu\\Documents\\lambda_package\\lambda_function.zip")


  environment {
    variables = {
      BUCKET_NAME                  = "bigdata-youtube-cleansed"
      s3_cleansed_layer            = "s3://bigdata-youtube-cleansed/projectyoutubedata/cleansed_statistics_reference_data/"
      glue_catalog_db_name         = "db-youtube-cleansed"
      glue_catalog_table_name      = "cleansed_statistics_reference_data_"
      write_data_operation         = "append"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_s3_attach,
    aws_iam_role_policy_attachment.lambda_glue_attach
  ]
}

