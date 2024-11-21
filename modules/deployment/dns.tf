resource "aws_route53_zone" "main" {
  name = var.domain
  force_destroy = true
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_route53domains_registered_domain" "domain" {
  domain_name = var.domain

  name_server {
    name = aws_route53_zone.main.name_servers[0]
  }
  name_server {
    name = aws_route53_zone.main.name_servers[1]
  }
  name_server {
    name = aws_route53_zone.main.name_servers[2]
  }
  name_server {
    name = aws_route53_zone.main.name_servers[3]
  }
}

resource "aws_route53_record" "root-record" {
  zone_id = aws_route53_zone.main.id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-record" {
  zone_id = aws_route53_zone.main.id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
