name       = "example-nlb"
vpc_id     = "vpc-0aabedb5c88362d87"
subnet_ids = ["subnet-0f80829a606ef2274", "subnet-0f80829a606ef2274"]

internal          = false
listener_port     = 80
listener_protocol = "TCP"
target_port       = 8080
target_protocol   = "TCP"
health_check = {
  protocol            = "TCP"
  port                = "8080"
  healthy_threshold   = 3
  unhealthy_threshold = 3
}

tags = {
  Project = "demo"
  Env     = "dev"
}
