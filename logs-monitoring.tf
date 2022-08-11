
#---------------------------------------------------------------- Cloudtrail

data "aws_caller_identity" "current" {}

# Logging Individual S3 Bucket Events By Using Basic Event Selectors
resource "aws_cloudtrail" "awscloudtrail-s3" {
  name = "tf-based-cloud-trail"
  s3_bucket_name = aws_s3_bucket.s3.id
  enable_logging = true
  #kms_key_id = ""
  s3_key_prefix = "log"
  cloud_watch_logs_role_arn     = aws_iam_role.cloud_trail.arn

  # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.s3bk.arn}:*" 
  include_global_service_events = false

/*  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = ["${aws_s3_bucket.s3.arn}/"]
    }
  }
*/

  # select data event

  advanced_event_selector {
    name = "Log PutObject and Delete Object events for S3 buckets"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
    field_selector {
      field  = "resources.type"
      #equals = ["AWS::S3::Object"]
      equals = ["AWS::S3::AccessPoint"]
    }
    field_selector {
      field  = "resources.ARN"
      starts_with = ["${aws_s3_bucket.s3.arn}/${aws_s3_bucket_object.event-folder.key}"]
      //starts_with = "arn:aws:s3:::bucket-dev65/event-folder/"
    }
    field_selector {
      field  = "eventName"
      equals = [
        "PutObject",
        "DeleteObject"
      ]
    }
  }
}

#---------------------------------------------------------------- Cloud watch

# Sending Events to CloudWatch Logs
resource "aws_cloudwatch_log_group" "s3bk" {
  name = "logs-${var.bucket-name}"
  retention_in_days = 0
}

#---------------------------------------------------------------- KMS : Disable
/*
resource "aws_kms_key" "key-trail" {
  description             = "KMS trail"
  deletion_window_in_days = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage = "ENCRYPT_DECRYPT"
}
*/
