resource "aws_s3_bucket" "html" {
  bucket = "${var.domain}"
}

resource "aws_s3_bucket_ownership_controls" "ownershiop" {
  bucket = aws_s3_bucket.html.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket = aws_s3_bucket.html.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownershiop,
    aws_s3_bucket_public_access_block.access,
  ]

  bucket = aws_s3_bucket.html.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.html.id

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = [
      "https://www.${var.domain}",
    ]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_website_configuration" "configuration" {
  bucket = aws_s3_bucket.html.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.html.id
  policy = templatefile("./deployment/s3-policy.json", { bucket = "${var.domain}" })

  depends_on = [aws_s3_bucket_ownership_controls.ownershiop, aws_s3_bucket.html, aws_s3_bucket_acl.acl]
}

resource "aws_s3_object" "index-html" {
  key        = "index.html"
  bucket     = aws_s3_bucket.html.id
  source     = "./html/index.html"
  etag = filemd5("./html/index.html")
  content_type = "text/html"
}
