module "data_model_ui_artefacts_bucket" {
  source      = "../../modules/s3"
  bucket_name = "${local.prefix}-${var.data_model_ui_artefacts_bucket_name}"
}

resource "aws_s3_bucket_policy" "data_model_ui_artefacts_bucket_policy" {
  depends_on = [module.data_model_ui_artefacts_bucket]
  bucket     = "${local.prefix}-${var.data_model_ui_artefacts_bucket_name}"
  policy     = data.aws_iam_policy_document.data_model_ui_artefacts_bucket_policy.json
}

data "aws_iam_policy_document" "data_model_ui_artefacts_bucket_policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-reserved/sso.amazonaws.com/${var.aws_region}/AWSReservedSSO_DOS-Developer_8bdf3f98a2591a2b",
        "${aws_iam_role.github_runner_iam_role.arn}",
      ]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "${module.data_model_ui_artefacts_bucket.s3_bucket_arn}"
    ]
  }

  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-reserved/sso.amazonaws.com/${var.aws_region}/AWSReservedSSO_DOS-Developer_8bdf3f98a2591a2b",
      "${aws_iam_role.github_runner_iam_role.arn}", ]
    }
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${module.data_model_ui_artefacts_bucket.s3_bucket_arn}/*",
    ]
  }
}
