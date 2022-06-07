data "aws_iam_policy_document" "event" {
  for_each = toset(var.identifier)
  statement {
    effect    = "Allow"
    actions   = ["ssm:StartAutomationExecution"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ssm_automation[each.value].arn]
  }
}

data "aws_iam_policy_document" "event_trust" {
  for_each = toset(var.identifier)
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# Generate a random string to add it to the name of the Target Group
resource "random_string" "iam_suffix" {
  length      = 12
  number      = true
  min_numeric = 12
}

resource "aws_iam_role" "event" {
  for_each           = toset(var.identifier)
  name               = substr("rds-scheduler-${each.key}-${random_string.iam_suffix.result}", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.event_trust["${each.value}"].json
}

resource "aws_iam_role_policy" "event" {
  for_each = toset(var.identifier)
  name     = substr("rds-scheduler-${each.key}-${random_string.iam_suffix.result}", 0, 64)
  policy   = data.aws_iam_policy_document.event[each.value].json
  role     = aws_iam_role.event[each.value].name
}


data "aws_iam_policy_document" "ssm_automation_trust" {
  for_each = toset(var.identifier)
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_automation" {
  for_each           = toset(var.identifier)
  name               = substr("rds-scheduler-ssm-${each.key}-${random_string.iam_suffix.result}", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.ssm_automation_trust["${each.value}"].json
}

resource "aws_iam_role_policy" "ssm_automation" {
  for_each      = toset(var.identifier)
  name          = substr("rds-scheduler-ssm-${each.key}-${random_string.iam_suffix.result}", 0, 64)
  role          = aws_iam_role.ssm_automation[each.value].name
  
  policy        = templatefile("${path.module}/policy_rds.json", {
    account     = data.aws_caller_identity.current.account_id
    identifier  = each.key
    region      = data.aws_region.current.name
  })

}

resource "aws_iam_role_policy_attachment" "ssm_automation" {
  for_each   = toset(var.identifier)
  role       = aws_iam_role.ssm_automation[each.value].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}
