name                = "example-scheduled-task"
schedule_expression = "rate(5 minutes)"
cluster_arn         = "arn:aws:ecs:us-east-1:123456789012:cluster/example"
task_definition_arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/example:1"
subnet_ids          = ["subnet-aaa111bbb", "subnet-ccc222ddd"]
security_group_ids  = ["sg-0123456789abcdef0"]
pass_role_arns = [
  "arn:aws:iam::123456789012:role/example-ecs-task-execution",
  "arn:aws:iam::123456789012:role/example-ecs-task"
]

tags = {
  Project = "demo"
  Env     = "dev"
}