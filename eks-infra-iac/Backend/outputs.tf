
output "bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.eks_bucket_remote_state.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.eks_bucket_remote_state.arn
}

output "table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.eks_lock_table.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.eks_lock_table.arn
}

