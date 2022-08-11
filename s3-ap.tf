
# ----------------------------------------------------------------------------------------------------------------------------------------------
# TEST : (Upload through accesspoint -> aws s3 cp /Users/rari3/Downloads/2.png s3://arn:aws:s3:ap-southeast-1:747913987992:accesspoint/rayrai-ap/2.png
# TEST  : (Download File ) aws s3 cp s3://arn:aws:s3:ap-southeast-1:747913987992:accesspoint/rayrai-ap/1.png /Users/rari3/Downloads/1.png
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
            "AWS": "${aws_iam_user.iam-rayrai.arn}"
            "AWS": "${aws_iam_role.iam-ray.arn}"
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_access_point.user-ap.arn}/object/*"
    }]
})
}
