resource "aws_security_group" "data_model_ui_sg" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = "${local.prefix}-lambda{local.workspace_suffix}"
  description = "Security group for application lambda"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
