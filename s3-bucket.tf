
# Resource to create s3 bucket

resource "aws_s3_bucket" "s3"{
  bucket = "${var.bucket-name}"

  tags = {
    key   = "name"
    value = "${var.tag-value-bucket}-s3"
  }
}

resource "aws_s3_bucket_object" "event-folder" {
  bucket = "${aws_s3_bucket.s3.id}"
  key    = "event-folder/"
}

# A resource to enable versioning on bucket
resource "aws_s3_bucket_versioning" "versioning_s3" {
  bucket = aws_s3_bucket.s3.bucket

  versioning_configuration {
    status = "${var.versioning_s3}"
  }
}

# Object Ownership
resource "aws_s3_bucket_ownership_controls" "s3-own" {
  bucket = aws_s3_bucket.s3.bucket

  rule {
    object_ownership = "${var.oject_owner}"
  }
}

# Block Public Access settings for this bucket
resource "aws_s3_bucket_public_access_block" "s3_public_block" {
  bucket = aws_s3_bucket.s3.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


# Bucket policy : Delegating access control to access points
resource "aws_s3_bucket_policy" "delegating-access" {
  bucket = aws_s3_bucket.s3.bucket
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement" : [
    {
        "Sid" : "admin-ap"
        "Effect": "Allow",
        "Principal" : { 
          "AWS": "*" 
        },
        "Action" : "*",
        "Resource" : "${aws_s3_bucket.s3.arn}",
        "Condition": {
            "StringEquals" : { 
                "s3:DataAccessPointAccount" : "${data.aws_caller_identity.current.account_id}" 
            }
        }
    },
    {
        "Sid": "AWSCloudTrailAclCheck",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
          "Action": "s3:GetBucketAcl",
          "Resource": "${aws_s3_bucket.s3.arn}"
    },
    {
          "Sid": "AWSCloudTrailWrite",
          "Effect": "Allow",
          "Principal": {
            "Service": "cloudtrail.amazonaws.com"
          },
          "Action": "s3:PutObject",
          "Resource": "${aws_s3_bucket.s3.arn}/log/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
          "Condition": {
            "StringEquals": {
              "s3:x-amz-acl": "bucket-owner-full-control"
            }
          }
    }
  ]
})
}
