resource "aws_s3_bucket" "tfe-bucket" {
  bucket = "${var.tag_prefix}-bucket"

  tags = {
    Name        = "${var.tag_prefix}-bucket"
  }
}

resource "aws_s3_bucket_acl" "tfe-bucket" {
  bucket = aws_s3_bucket.tfe-bucket.id
  acl    = "private"
}

resource "aws_iam_role" "role" {
  name = "${var.tag_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.tag_prefix}-instance"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.tag_prefix}-bucket"
  role = aws_iam_role.role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${var.tag_prefix}-bucket",
                "arn:aws:s3:::*/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
})
}
