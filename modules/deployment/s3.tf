resource "aws_s3_bucket" "html" {
  bucket = "${var.domain}"
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.domain}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = aws_s3_bucket.html.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.html.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership
  ]

  bucket = aws_s3_bucket.html.id
  acl    = "private"
}

resource "aws_s3_object" "index-html" {
  key        = "index.html"
  bucket     = aws_s3_bucket.html.id
  source     = "./html/index.html"
  etag = filemd5("./html/index.html")
  content_type = "text/html"
}
