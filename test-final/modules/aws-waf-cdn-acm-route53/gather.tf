data "aws_route53_zone" "zone" {
  name         = var.domain-name
  private_zone = false
}
