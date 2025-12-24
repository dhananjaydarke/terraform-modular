name = "example-ecr-repo"

force_delete = true
untagged_retention_days = 30

# Common tags applied to resources created by this module
# Update these to match your tagging standards
# For example: { Project = "demo", Env = "dev" }
tags = {
  Project = "demo"
  Env     = "dev"
}
