import json
import logging
import boto3

rekog_client = boto3.client('rekognition')
s3 = boto3.resource('s3')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info("Event received.")
    logger.info("Received event: " + json.dumps(event))
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        logger.info('Detecting labels for ' + key) 
        detection_response = rekog_client.detect_labels(Image={'S3Object':{'Bucket':bucket,'Name':key}},
        MaxLabels=10)
        detected_labels = _detect_labels(detection_response)
        _score_labels(detection_response)
        
        logger.info('Detecting text for ' + key) 
        detection_response = rekog_client.detect_text(Image={'S3Object':{'Bucket':bucket,'Name':key}})
        _detect_text(detection_response)
        
        logger.info('Detecting celebrities for ' + key) 
        detection_response = rekog_client.recognize_celebrities(Image={'S3Object':{'Bucket':bucket,'Name':key}})
        _detect_celebrities(detection_response)
        

def _detect_labels(labels):
    detected_labels = []
    for label in labels['Labels']:
        detected_labels.append({"label": label['Name'], "confidence": label['Confidence']})
        logger.info("Label: " + label['Name'])
        logger.info("Confidence: " + str(label['Confidence']))
        logger.info("Instances:")
        for instance in label['Instances']:
            logger.info("  Bounding box")
            logger.info("    Top: " + str(instance['BoundingBox']['Top']))
            logger.info("    Left: " + str(instance['BoundingBox']['Left']))
            logger.info("    Width: " +  str(instance['BoundingBox']['Width']))
            logger.info("    Height: " +  str(instance['BoundingBox']['Height']))
            logger.info("  Confidence: " + str(instance['Confidence']))

        logger.info("Parents:")
        for parent in label['Parents']:
            logger.info("   " + parent['Name'])
        logger.info("----------")
    return detected_labels

def _detect_text(texts):
    detected_texts = []
    for text in texts['TextDetections']:
        detected_texts.append({"text": text['DetectedText'], "type": text['Type'], "confidence": text['Confidence']})
        logger.info("Text: " + text['DetectedText'])
        logger.info("Type: " + text['Type'])
        logger.info("Confidence: " + str(text['Confidence']))
        logger.info("  Bounding box")
        logger.info("    Top: " + str(text['Geometry']['BoundingBox']['Top']))
        logger.info("    Left: " + str(text['Geometry']['BoundingBox']['Left']))
        logger.info("    Width: " +  str(text['Geometry']['BoundingBox']['Width']))
        logger.info("    Height: " +  str(text['Geometry']['BoundingBox']['Height']))
        logger.info("  Polygons:")
        for coordinates in text['Geometry']['Polygon']:
            logger.info("  Polygon")
            logger.info("    X: " + str(coordinates['X']))
            logger.info("    Y: " + str(coordinates['Y']))
        logger.info("----------")
    return detected_texts

def _detect_celebrities(celebrities):
    detected_celebrities = []
    logger.info(celebrities)
    for celebrity in celebrities['CelebrityFaces']:
        detected_celebrities.append({"url": celebrity['Urls'], "name": celebrity['Name'], "confidence": celebrity['Face']['Confidence']})
        logger.info('Name: ' + celebrity['Name'])
        logger.info('Id: ' + celebrity['Id'])
        logger.info('Position:')
        logger.info('   Left: ' + '{:.2f}'.format(celebrity['Face']['BoundingBox']['Height']))
        logger.info('   Top: ' + '{:.2f}'.format(celebrity['Face']['BoundingBox']['Top']))
        logger.info('Info')
        for url in celebrity['Urls']:
            logger.info('   ' + url)
        logger.info("----------")
    return detected_celebrities

def _score_labels(labels):
    pass
    # for label in labels:


def _add_totals(name, points):
    # track number of criterias being applied to this image
    _criteria_filtered += 1
    
    # track the confidence of each criteria taken from rekognition
    _total_score += points
    
    # (optional) keep track of the individual points earned for each criteria 
    _found_criterias =  {"name": name, "points": points}
    _found_labels.update(_found_criterias)