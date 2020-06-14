####################################################
# outputs.tf
####################################################

output "image_processor_lambda_id" {
  value = "${aws_lambda_function.image_processor_lambda.id}"
}

output "image_processor_lambda_arn" {
  value = "${aws_lambda_function.image_processor_lambda.arn}"
}

output "image_rekognition_file_upload_bucket_arn" {
  value = "${aws_s3_bucket.image_rekognition_file_upload_bucket.arn}"
}
 
output "image_rekognition_file_upload_log_bucket_arn" {
  value = "${aws_s3_bucket.image_rekognition_file_upload_log_bucket.arn}"
}