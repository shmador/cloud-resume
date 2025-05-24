data "aws_route53_zone" "primary" {
  name         = var.mydomain
  private_zone = false
}