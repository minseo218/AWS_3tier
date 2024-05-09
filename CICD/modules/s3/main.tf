# S3 버킷 생성
resource "aws_s3_bucket" "test_artifacts_minseo" {
  bucket = "test-artifacts-minseo"
}
# S3 버킷 정책 설정
resource "aws_s3_bucket_policy" "test_artifacts_minseo_policy" {
  bucket = aws_s3_bucket.test_artifacts_minseo.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyPublicAccess",
        Effect    = "Deny",
        Principal = "*",
        Action    = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          #"s3:GetBucketVersioning",
          "s3:PutObject"

        ],
        Resource  = [
          "${aws_s3_bucket.test_artifacts_minseo.arn}/*",
          aws_s3_bucket.test_artifacts_minseo.arn
        ]
      }
    ]
  })
}