resource "aws_cloudwatch_event_rule" "rds_stop" {
  for_each = toset(var.identifier)
  name                = "rds-scheduler-${each.key}-stop"
  description         = "Stops RDS instance on a schedule"
  schedule_expression = "cron(${var.cron_stop})"
}

resource "aws_cloudwatch_event_target" "rds_stop" {
  for_each = toset(var.identifier)
  arn   = "arn:aws:ssm:${data.aws_region.current.name}::automation-definition/AWS-StopRdsInstance:$DEFAULT"
  input = jsonencode(
    {
      AutomationAssumeRole = [
        aws_iam_role.ssm_automation[each.value].arn,
      ]
      InstanceId = each.key
    }
  )
  role_arn  = aws_iam_role.event[each.value].arn
  rule      = aws_cloudwatch_event_rule.rds_stop[each.value].name
  target_id = "rds-scheduler-${each.key}-stop"
}

resource "aws_cloudwatch_event_rule" "rds_start" {
  for_each = toset(var.identifier)
  name                = "rds-scheduler-${each.key}-start"
  description         = "Starts RDS instance on a schedule"
  schedule_expression = "cron(${var.cron_start})"
}

resource "aws_cloudwatch_event_target" "rds_start" {
  for_each = toset(var.identifier)
  arn   = "arn:aws:ssm:${data.aws_region.current.name}::automation-definition/AWS-StartRdsInstance:$DEFAULT"
  input = jsonencode(
    {
      AutomationAssumeRole = [
        aws_iam_role.ssm_automation[each.value].arn,
      ]
      InstanceId = each.key
    }
  )
  role_arn  = aws_iam_role.event[each.value].arn
  rule      = aws_cloudwatch_event_rule.rds_start[each.value].name
  target_id = "rds-scheduler-${each.key}-start"
}
