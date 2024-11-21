resource "aws_cloudfront_origin_access_control" "access" {
  name                              = "CloudFront S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name              = aws_s3_bucket.html.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.access.id
    origin_id                = var.domain
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [
    "www.${var.domain}",
    "${var.domain}"
  ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

   # Cache behavior with precedence 0
#  ordered_cache_behavior {
#    path_pattern     = "/content/immutable/*"
#    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#    cached_methods   = ["GET", "HEAD", "OPTIONS"]
#    target_origin_id = local.s3_origin_id
#
#    forwarded_values {
#      query_string = false
#      headers      = ["Origin"]
#
#      cookies {
#        forward = "none"
#      }
#    }
#
#    min_ttl                = 0
#    default_ttl            = 86400
#    max_ttl                = 31536000
#    compress               = true
#    viewer_protocol_policy = "redirect-to-https"
#  }

  # Cache behavior with precedence 1
#  ordered_cache_behavior {
#    path_pattern     = "/content/*"
#    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#    cached_methods   = ["GET", "HEAD"]
#    target_origin_id = local.s3_origin_id
#
#    forwarded_values {
#      query_string = false
#
#      cookies {
#        forward = "none"
#      }
#    }
#
#    min_ttl                = 0
#    default_ttl            = 3600
#    max_ttl                = 86400
#    compress               = true
#    viewer_protocol_policy = "redirect-to-https"
#  }
#
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}