variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "app"
}

variable "image_count_to_keep" {
  description = "Number of images to retain in the repository"
  type        = number
  default     = 10
}
