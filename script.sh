#!/bin/bash

# Variables
RDS_INSTANCE_IDENTIFIER="your-rds-instance-identifier"
SNAPSHOT_IDENTIFIER="your-snapshot-identifier-$(date +%Y-%m-%d-%H-%M-%S)"
S3_BUCKET_NAME="your-s3-bucket-name"
AWS_REGION="your-aws-region"

# Create RDS Snapshot
echo "Creating RDS snapshot..."
aws rds create-db-snapshot \
    --db-instance-identifier $RDS_INSTANCE_IDENTIFIER \
    --db-snapshot-identifier $SNAPSHOT_IDENTIFIER \
    --region $AWS_REGION

# Wait for the snapshot to be available
echo "Waiting for snapshot to be available..."
aws rds wait db-snapshot-available \
    --db-snapshot-identifier $SNAPSHOT_IDENTIFIER \
    --region $AWS_REGION

# Copy RDS snapshot to S3
SNAPSHOT_ARN=$(aws rds describe-db-snapshots \
    --db-snapshot-identifier $SNAPSHOT_IDENTIFIER \
    --region $AWS_REGION \
    --query "DBSnapshots[0].DBSnapshotArn" \
    --output text)

echo "Copying snapshot to S3..."
aws rds export-task \
    --export-task-identifier "export-task-$SNAPSHOT_IDENTIFIER" \
    --source-arn $SNAPSHOT_ARN \
    --s3-bucket-name $S3_BUCKET_NAME \
    --iam-role-arn "arn:aws:iam::your-account-id:role/your-iam-role" \
    --kms-key-id "arn:aws:kms:your-region:your-account-id:key/your-kms-key-id" \
    --region $AWS_REGION

echo "Snapshot $SNAPSHOT_IDENTIFIER has been exported to S3 bucket $S3_BUCKET_NAME."

# Optional: Cleanup old snapshots (e.g., older than 7 days)
echo "Cleaning up old snapshots..."
aws rds describe-db-snapshots \
    --db-instance-identifier $RDS_INSTANCE_IDENTIFIER \
    --region $AWS_REGION \
    --query "DBSnapshots[?SnapshotCreateTime<='$(date -d '7 days ago' +%Y-%m-%dT%H:%M:%S)'].DBSnapshotIdentifier" \
    --output text | xargs -n 1 -I {} aws rds delete-db-snapshot --db-snapshot-identifier {} --region $AWS_REGION

echo "Old snapshots have been cleaned up."

echo "Process completed successfully!"
