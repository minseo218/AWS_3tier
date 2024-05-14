resource "aws_iam_instance_profile" "test_profile" {
  name = var.instance-profile-name
  role = aws_iam_role.iam-role.name
}
#
## IAM role resource
#data "aws_iam_role" "iam-role-cicd" {
#  name = "EC2InstanceRole_cicd"
#}
#
## Creating IAM instance profile and attaching the role
#resource "aws_iam_instance_profile" "test_profile" {
#  name = var.instance-profile-name
#  roles = [
#    aws_iam_role.iam-role.name,
#    data.aws_iam_role.iam-role-cicd.name
#  ]
#}