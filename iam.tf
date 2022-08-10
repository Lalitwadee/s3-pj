
#------------------------------------------------ Create IAM user
# and then take action in console to create access key before use it.

resource "aws_iam_user" "iam-rayrai" {
  name = "${var.iam-user}"
}

resource "aws_iam_user_policy_attachment" "attach-user" {
  user       = "${aws_iam_user.iam-rayrai.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
