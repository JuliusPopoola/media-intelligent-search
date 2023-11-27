resource "aws_iam_role" "lang_chain_llm" {
  name = "${var.lang_chain_llm_label}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lang_chain_llm" {
  name = "${var.lang_chain_llm_label}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "bedrock:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lang_chain_llm_iam_policy_basic_execution" {
  role       = aws_iam_role.lang_chain_llm.id
  policy_arn = aws_iam_policy.lang_chain_llm.arn
}
