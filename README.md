# RDS-DR
This repo conatins the bash script for DR in AWS RDS

Please replace the placeholders :
your-rds-instance-identifier: The identifier of your RDS instance.
your-snapshot-identifier: Base identifier for your snapshot.
your-s3-bucket-name: The name of your S3 bucket.
your-aws-region: Your AWS region.
arn:aws:iam::your-account-id:role/your-iam-role: The IAM role ARN with the necessary permissions.
arn:aws:kms:your-region:your-account-id:key/your-kms-key-id: The KMS key ARN used for encryption (if required).

Ensure to give necessary IAM Role