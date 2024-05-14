resource "aws_iam_role" "iam-role" {
  name               = var.iam-role
  assume_role_policy = file("${path.module}/iam-role.json")
}

#resource "aws_iam_role_policy_attachment" "ssm_attachment" {
#  role       = aws_iam_role.iam-role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
#}