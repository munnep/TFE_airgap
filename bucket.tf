resource "aws_s3_bucket" "tfe-bucket" {
  bucket = "${var.tag_prefix}-bucket"

  tags = {
    Name = "${var.tag_prefix}-bucket"
  }
}

resource "aws_s3_bucket" "tfe-bucket-software" {
  bucket = "${var.tag_prefix}-software"

  tags = {
    Name = "${var.tag_prefix}-software"
  }
}


resource "aws_s3_object" "object_airgap" {
  bucket = "${var.tag_prefix}-software"
  key    = var.filename_airgap
  source = "airgap/${var.filename_airgap}"
}

resource "aws_s3_object" "object_license" {
  bucket = "${var.tag_prefix}-software"
  key    = var.filename_license
  source = "airgap/${var.filename_license}"
}

resource "aws_s3_object" "object_bootstrap" {
  bucket = "${var.tag_prefix}-software"
  key    = var.filename_bootstrap
  source = "airgap/${var.filename_bootstrap}"
}

resource "aws_s3_object" "object_certificate_private_key" {
  bucket = "${var.tag_prefix}-software"
  key    = var.filename_certificate_private_key
  source = "airgap/${var.filename_certificate_private_key}"
}

resource "aws_s3_object" "object_certificate_fullchain" {
  bucket = "${var.tag_prefix}-software"
  key    = var.filename_certificate_fullchain
  source = "airgap/${var.filename_certificate_fullchain}"
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
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.tag_prefix}-bucket",
          "arn:aws:s3:::${var.tag_prefix}-software",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : "*"
      }
    ]
  })
}