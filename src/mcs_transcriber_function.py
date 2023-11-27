import json
import os
import time
import boto3
from pathlib import Path

REGION = os.environ["REGION"]
TRANSCRIBE_ROLE_ARN = os.environ["TRANSCRIBE_ROLE_ARN"]
TRANSCRIBE_OUTPUT_BUCKET = os.environ["TRANSCRIBE_OUTPUT_BUCKET"]

transcribe = boto3.client('transcribe', region_name=REGION)

def lambda_handler(event, context):
    print(event)

    eventName = event["Records"][0]["eventName"]
    statusCode = 200
    body = {}
    
    if "objectcreated" not in eventName.lower():
        statusCode = 400
        body = {
            'error': 'The transcribe request is not valid'
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
        inputBucket = event["Records"][0]["s3"]["bucket"]["name"]
        inputBucketKey = event["Records"][0]["s3"]["object"]["key"]
        
        job_name = get_filename_without_ext(inputBucketKey)
        transcribe.start_transcription_job(
            TranscriptionJobName = job_name,
            Media = {
                'MediaFileUri': 's3://'+ inputBucket + '/' + inputBucketKey
            },
            OutputBucketName = TRANSCRIBE_OUTPUT_BUCKET,
            OutputKey = job_name + '.json', 
            Subtitles = {
                'Formats': [
                    'srt'
                ],
                'OutputStartIndex': 1 
            },
            JobExecutionSettings={
                'AllowDeferredExecution': True,
                'DataAccessRoleArn': TRANSCRIBE_ROLE_ARN
            },
            IdentifyLanguage = True
        )

        while True:
            status = transcribe.get_transcription_job(TranscriptionJobName = job_name)
            if status['TranscriptionJob']['TranscriptionJobStatus'] in ['COMPLETED', 'FAILED']:
                break
            print("Not ready yet...")
            time.sleep(5)

        print(status)
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
        
def get_filename_without_ext(filePath):
    return Path(filePath).stem