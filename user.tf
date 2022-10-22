resource "aws_iam_user" "techchallenge" {
  name = "techchallenge"
}

resource "aws_iam_access_key" "techchallenge" {
  user = aws_iam_user.techchallenge.name
}

resource "aws_iam_user_policy" "techchallenge" {
  name = "techchallenge"
  user = aws_iam_user.techchallenge.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "EKS:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_secretsmanager_secret" "techchallenge" {
  name = "techchallenge"
}

resource "aws_secretsmanager_secret_version" "techchallenge" {
  secret_id     = aws_secretsmanager_secret.techchallenge.id
  secret_string = jsonencode({ "AccessKey" = aws_iam_access_key.techchallenge.id, "SecretAccessKey" = aws_iam_access_key.techchallenge.secret })
}