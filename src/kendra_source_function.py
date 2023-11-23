import json
import os
import boto3
from pathlib import Path

REGION = os.environ["REGION"]
KENDRA_INDEX_NAME = os.environ["KENDRA_INDEX_NAME"]
KENDRA_BATCH_PUT_ROLE_ARN = os.environ["KENDRA_BATCH_PUT_ROLE_ARN"]

OVERLAP_RANGE = os.environ["OVERLAP_RANGE"]
BATCH_SIZE = os.environ["BATCH_SIZE"]

kendra = boto3.client('kendra', region_name=REGION)
s3 = boto3.client('s3', region_name=REGION)

def lambda_handler(event, context):
    print(event)

    statusCode = 200
    body = {}
    
    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    object_key = event["Records"][0]["s3"]["object"]["key"]

    extension = Path(object_key).suffix
    if ".json" not in extension.lower():
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

    try:
        
        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        response_body = json.loads(response["Body"].read().decode("utf-8"))
        list_of_items = [item for item in response_body["results"]["items"]]

        documents = extract_data(object_key, list_of_items)        
        batch_upload_text(documents)
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

def extract_data(object_key, list_of_items):
    counter = 1
    documents = []
    title = Path(object_key).stem
    number_of_items = len(list_of_items)
    for index in range(0, number_of_items, int(OVERLAP_RANGE)):
        current_length = index + int(BATCH_SIZE)
        current_batch_size = current_length if current_length < number_of_items  else number_of_items
        sub_document = " ".join(word["alternatives"][0]["content"] for word in list_of_items[index:current_batch_size])
            
        print(f"For index: {str(index)} | Counter: {counter} | The text: -> {sub_document}")
        id = f"{title}_{counter}"
        documents.append(compose_document(id=id, title=title, text=sub_document))
        counter += 1
    return documents

def batch_upload_text(documents):
    number_of_documents = len(documents)
    for index in range(0, number_of_documents, 10):
        range_size = index + 10
        section = documents[index:10] if range_size < len(documents) else documents[index:number_of_documents]
        result = kendra.batch_put_document(
                IndexId = KENDRA_INDEX_NAME,
                Documents = section
            )
        print(result)
    
def compose_document(id, title, text):
    return {
        "Id": id,
        "Blob": text,
        "ContentType": "PLAIN_TEXT",
        "Title": title
    }
