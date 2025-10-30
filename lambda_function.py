import boto3
import os
import json
import pandas as pd
import awswrangler as wr

def lambda_handler(event, context):
    try:
        # Input bucket/object from event
        for record in event['Records']:
            source_bucket = record['s3']['bucket']['name']
            source_key = record['s3']['object']['key']

            # Read JSON directly from S3 using Data Wrangler
            s3_path = f"s3://{source_bucket}/{source_key}"
            df = wr.s3.read_json(path=s3_path, lines=True)
            
            # Destination path
            dest_bucket = os.environ['BUCKET_NAME']
            dest_path = f"s3://{dest_bucket}/projectyoutubedata/cleansed_statistics_reference_data/{source_key.replace('.json', '.parquet')}"
            
            # Write Parquet to S3 with Data Wrangler and update Glue Catalog
            wr.s3.to_parquet(
                df=df, 
                path=dest_path,
                database=os.environ.get('glue_catalog_db_name', 'db_youtube_raw'),
                table=os.environ.get('glue_catalog_table_name', 'raw_statistics'),
                mode=os.environ.get('write_data_operation', 'append')
            )

            # (Optional) Update Glue Catalog
            # glue.create_table(...) or glue.update_table(...) if schema changes

        return {"status": "success"}
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"status": "failed", "error": str(e)}
