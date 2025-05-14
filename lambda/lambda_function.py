import json
import requests
import boto3
from datetime import datetime
import os

def lambda_handler(event, context):
    API_KEY = os.environ['WEATHER_API_KEY']
    LOCATION = os.environ['LOCATION']
    BUCKET_NAME = os.environ['BUCKET_NAME']
    
    url = f'https://api.weatherapi.com/v1/current.json?key={API_KEY}&q={LOCATION}&aqi=no'
    
    response = requests.get(url)
    weather_data = response.json()
    
    filename = f'weather/weather_{LOCATION}_{datetime.utcnow().strftime("%Y%m%d_%H%M%S")}.json'
    
    s3 = boto3.client('s3')
    s3.put_object(Bucket=BUCKET_NAME, Key=filename, Body=json.dumps(weather_data))
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Uploaded {filename} to {BUCKET_NAME}')
    }