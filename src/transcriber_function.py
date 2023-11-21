import json
import os
import time
import boto3

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
        body = {
            'success': True,
            'message': 'The transcribe request does not require processing, event name is ' +  eventName
        }
        
        return {
            'statusCode': statusCode,
            'body': json.dumps(body),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }        

    inputBucket = event["Records"][0]["s3"]["bucket"]["name"]
    inputBucketKey = event["Records"][0]["s3"]["object"]["key"]

    try:
        job_name = inputBucketKey
        transcribe.start_transcription_job(
            TranscriptionJobName = job_name,
            Media = {
                'MediaFileUri': 's3://'+ inputBucket + '/' + inputBucketKey
            },
            OutputBucketName = TRANSCRIBE_OUTPUT_BUCKET,
            OutputKey = job_name + '.json', 
            Subtitles = {
                'Formats': [
                    'vtt','srt'
                ],
                'OutputStartIndex': 1 
            },
            Settings = {
                 'ShowSpeakerLabels': True,
            },
            JobExecutionSettings={
                'AllowDeferredExecution': True,
                'DataAccessRoleArn': TRANSCRIBE_ROLE_ARN
            },
            IdentifyLanguage = True,
            LanguageOptions=[
                'af-ZA'|'ar-AE'|'ar-SA'|'da-DK'|'de-CH'|'de-DE'|'en-AB'|'en-AU'|'en-GB'|'en-IE'|'en-IN'|'en-US'|'en-WL'|'es-ES'|'es-US'|'fa-IR'|'fr-CA'|'fr-FR'|'he-IL'|'hi-IN'|'id-ID'|'it-IT'|'ja-JP'|'ko-KR'|'ms-MY'|'nl-NL'|'pt-BR'|'pt-PT'|'ru-RU'|'ta-IN'|'te-IN'|'tr-TR'|'zh-CN'|'zh-TW'|'th-TH'|'en-ZA'|'en-NZ'|'vi-VN'|'sv-SE',
            ],
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