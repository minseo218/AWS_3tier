resource "aws_iam_role_policy" "iam-policy" {
  name   = var.iam-policy
  role   = aws_iam_role.iam-role.id
  policy = file("${path.module}/iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "code_deploy_attachment" {
  role       = aws_iam_role.iam-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

#resource "aws_iam_role_policy_attachment" "ssm_attachment" {
#  role       = aws_iam_role.iam-role.id
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
#}
