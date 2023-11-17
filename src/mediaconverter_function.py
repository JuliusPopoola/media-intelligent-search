import json
import os
import boto3
from boto3.dynamodb.conditions import Key

OUTPUT_BUCKET = os.environ["OUTPUT_BUCKET"]
MEDIA_CONVERT_ROLE = os.environ["MEDIACONVERT_ROLE_ARN"]
MEDIA_CONVERT_ENDPOINT = os.environ["MEDIACONVERT_ENDPOINT"]

REGION = os.environ["REGION"]

def lambda_handler(event, context):
    print(event)

    eventName = event["Records"][0]["eventName"]
    statusCode = 200
    body = {}
    
    if "objectcreated" not in eventName.lower():
        body = {
            'success': True,
            'message': 'The event type does not require processing, event name is ' +  eventName
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

    destinationS3 = 's3://' + OUTPUT_BUCKET + '/$fn$/'

    try:
        jobMetadata = {
            'assetID': inputBucketKey
        }

        client = boto3.client('mediaconvert', region_name=REGION, endpoint_url=MEDIA_CONVERT_ENDPOINT, verify=False)

        with open('job.json') as json_data:
            jobSettings = json.load(json_data)

        jobSettings['Inputs'][0]['FileInput'] = 's3://'+ inputBucket + '/' + inputBucketKey
        jobSettings['OutputGroups'][0]['OutputGroupSettings']['HlsGroupSettings']['Destination'] = destinationS3 + "/hls/"
        jobSettings['OutputGroups'][1]['OutputGroupSettings']['FileGroupSettings']['Destination'] = destinationS3 + "/mp4/"
        print('jobSettings:')
        print(json.dumps(jobSettings))

        job = client.create_job(Role=MEDIA_CONVERT_ROLE, UserMetadata=jobMetadata, Settings=jobSettings)
        print(json.dumps(job, default=str))

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
        return {
            'statusCode': statusCode,
            'body': json.dumps(body),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }