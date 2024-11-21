resource aws_acm_certificate cert {
  domain_name                = var.domain
  subject_alternative_names  = [
    "www.${var.domain}",
    "*.${var.domain}"
  ]
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}
