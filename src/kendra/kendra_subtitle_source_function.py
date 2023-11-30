import json
import os
import time
import boto3
from pathlib import Path

REGION = os.environ["REGION"]
KENDRA_INDEX_NAME = os.environ["KENDRA_INDEX_NAME"]
KENDRA_BATCH_PUT_ROLE_ARN = os.environ["KENDRA_BATCH_PUT_ROLE_ARN"]

kendra = boto3.client('kendra', region_name=REGION)
s3 = boto3.client('s3', region_name=REGION)

def lambda_handler(event, context):
    print(event)

    statusCode = 200
    body = {}
    
    inputBucket = event["Records"][0]["s3"]["bucket"]["name"]
    inputBucketKey = event["Records"][0]["s3"]["object"]["key"]

    extension = Path(inputBucketKey).suffix
    if ".srt" not in extension.lower():
        body = {
            'success': True,
            'message': 'The reference file not valid, only SRT files are processed'
        }
        
        return {
            'statusCode': statusCode,
            'body': json.dumps(body),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        } 
  
    counter = 0
    index = 0
    document = {}
    documents = []

    try:
        response = s3.get_object(Bucket=inputBucket, Key=inputBucketKey)
        object_content = response["Body"].read().decode("utf-8").split("\n")

        title = Path(inputBucketKey).stem
        for item in object_content:
            if "".__eq__(item.strip()):
                index = 0
                document = {}
            else:
                match index:
                    case 0:
                        document["document_id"] = item
                    case 1:
                        document["start_time"], document["end_time"] = split_timestamp(item)
                    case 2:
                        document["content"] = item
                        documents.append(transform(title, document))
                        
                        if counter == 9:
                            counter = 0
                            result = kendra.batch_put_document(
                                IndexId = KENDRA_INDEX_NAME,
                                Documents = documents
                            )
                            print(result)
                            documents = []
                        else:
                            counter += 1
                index += 1

        if counter > 0:
            result = kendra.batch_put_document(
                IndexId = KENDRA_INDEX_NAME,
                Documents = documents
            )
            print(result)
            
        body = {
            'success': True
        }

    except Exception as exception:
        print(exception)
        statusCode = 500
        body = {
            'error': str(exception)
        }
        raise

    finally:
        print('Status Code:' + str(statusCode))
        print(json.dumps(body))
        return {
            'statusCode': statusCode,
            'body': json.dumps(body),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
   
def split_timestamp(timestamp):
    index = timestamp.index("-->")
    start_time = timestamp[0:index].strip()
    end_time = timestamp[index+3:].strip()
    return start_time, end_time
    
def transform(title, doc):
    return {
        "Id": doc["document_id"],
        "Blob": json.dumps(doc),
        "ContentType": "PLAIN_TEXT",
        "Title": title
    }
