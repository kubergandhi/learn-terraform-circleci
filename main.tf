provider "aws" {
  region = var.region

  default_tags {
    tags = {
      hashicorp-learn = "circleci"
    }
  }
}

resource "random_uuid" "randomid" {}

resource "aws_s3_bucket" "app" {
  tags = {
    Name          = "App Bucket"
    public_bucket = true
  }
  bucket        = "${var.app}.${var.label}.${random_uuid.randomid.result}"
  force_destroy = true
}

resource "aws_s3_object" "app" {
  key          = "index.html"
  bucket       = aws_s3_bucket.app.id
  content      = file("./assets/index.html")
  content_type = "text/html"
  
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.app.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {

        Effect    = "Allow"
        Principal = "*"
        Action    = [
                "s3:GetObject"
            ]
        Resource = [
          "${aws_s3_bucket.app.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "terramino" {
  bucket = aws_s3_bucket.app.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
