resource "aws_s3_bucket" "image_rekognition_file_upload_bucket" {
  bucket        = "image-rekognition-file-uploads"
  acl           = "private"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.image_rekognition_file_upload_log_bucket.id
    target_prefix = "log/"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  tags = {
    Name        = "Images that were uploaded for Rekognition processing"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "image_rekognition_file_upload_log_bucket" {
  bucket        = "image-rekognition-file-upload-logs"
  acl           = "log-delivery-write"
  force_destroy = true
}