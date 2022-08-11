
#------------------------------------------------ Create IAM user
# and then take action in console to create access key before use it.

resource "aws_iam_user" "iam-rayrai" {
  name = "${var.iam-user}"
}

resource "aws_iam_user_policy_attachment" "attach-user" {
  user       = "${aws_iam_user.iam-rayrai.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#----------------------------------------------------- Create iam role : test upload
# and then take action in console to create access key before use it.

resource "aws_iam_role" "iam-ray" {
  name = "${var.iam-role}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})

  inline_policy {
    name = "ray_inline_policy"


    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket-name}",
        "arn:aws:s3:::${var.bucket-name}/*"
      ]

    }
  ]
})
}

  tags = {
    name = "name"
    value = "${var.tag-value-bucket}-${var.iam-role}"
  }
}

resource "aws_iam_instance_profile" "role_profile" {
  name = "${var.iam-role}"
  role = aws_iam_role.iam-ray.name
}

#----------------------------------------------------- Create iam role : cloud_trail
 
resource "aws_iam_role" "cloud_trail" {
  name = "cloudTrail-cloudWatch-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "role-policy-ctcw" {
  name = "cloudTrail-cloudWatch-policy"
  role = aws_iam_role.cloud_trail.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream2014110",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.s3bk.arn}:*"
            ]
        },
        {
            "Sid": "AWSCloudTrailPutLogEvents20141101",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.s3bk.arn}:*"
            ]
        }
    ]
}
EOF
}
