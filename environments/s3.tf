resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.site.id
  key    = "index.html"
  source = "../src/front/index.html"
  content_type = "text/html"
  etag = filemd5("../src/front/index.html")
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.site.id
  key    = "error.html"
  source = "../src/front/error.html"
  content_type = "text/html"
  etag = filemd5("../src/front/error.html")
}

resource "aws_s3_object" "visitor_js" {
  bucket       = aws_s3_bucket.site.id
  key          = "visitors.js"
  source       = "../src/front/visitors.js"
  content_type = "application/javascript"
  etag         = filemd5("../src/front/visitors.js") 
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}
