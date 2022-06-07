variable "identifier" {
  description = "RDS instances identifier for schedule list"
  type        = list(string)
}
variable "cron_stop" {
  description = "Cron expression to define when to trigger a stop of the DB"
}

variable "cron_start" {
  description = "Cron expression to define when to trigger a start of the DB"
}
variable "enable" {
  default = true
}
