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

resource "aws_iam_user_policy" "ecs-fargate-deploy" {
  user = aws_iam_user.ci_user.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService",
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}
