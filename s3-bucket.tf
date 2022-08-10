
# Resource to create s3 bucket

resource "aws_s3_bucket" "s3"{
  bucket = "${var.bucket-name}"

  tags = {
    key   = "name"
    value = "${var.tag-value-bucket}-s3"
  }
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
        "Effect": "Allow",
        "Principal" : { 
            "AWS": "*" 
        },
        "Action" : "*",
        "Resource" : "arn:aws:s3:::${var.bucket-name}",
        "Condition": {
            "StringEquals" : { 
                "s3:DataAccessPointAccount" : "${var.account_id}" 
            }
        }
    }
]
})
}
