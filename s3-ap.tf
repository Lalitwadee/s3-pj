
# ----------------------------------------------------------------------------------------------------------------------------------------------
# TEST : (Upload through accesspoint -> aws s3 cp /Users/rari3/Downloads/2.png s3://arn:aws:s3:us-east-1:747913987992:accesspoint/ap-ray/2.png)
# TEST  : (Download File ) aws s3 cp s3://arn:aws:s3:us-east-1:747913987992:accesspoint/ap-ray/1.png /Users/rari3/Downloads/1.png
# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_s3_access_point" "user-ap" {
  bucket = aws_s3_bucket.s3.bucket
  name   = "${var.ap-name}"

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_s3control_access_point_policy" "ap-policy" {
  access_point_arn = aws_s3_access_point.user-ap.arn

  policy = jsonencode({
    "Version":"2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${var.account_id}:user/${var.iam-user}"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:${var.region}:${var.account_id}:accesspoint/${var.ap-name}/object/*"
    }]
})
}
