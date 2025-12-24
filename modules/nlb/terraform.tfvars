name       = "example-nlb"
vpc_id     = "vpc-0123456789abcdef0"
subnet_ids = ["subnet-aaa111bbb", "subnet-ccc222ddd"]

internal           = false
listener_port      = 80
listener_protocol  = "TCP"
target_port        = 8080
target_protocol    = "TCP"
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
