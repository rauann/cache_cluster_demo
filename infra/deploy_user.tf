resource "aws_iam_user" "ci_user" {
  name = "ci-deploy-user"
}

resource "aws_iam_user_policy" "ci_ecr_access" {
  user = aws_iam_user.ci_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecr:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_ecr_repository.cache_cluster_demo_repo.arn}"
    }
  ]
}
EOF
}
