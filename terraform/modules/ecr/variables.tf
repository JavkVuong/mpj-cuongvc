variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the ECR repository."
  type        = string
  default     = "MUTABLE"

  validation {
    condition = contains([
      "MUTABLE",
      "IMMUTABLE",
      "MUTABLE_WITH_EXCLUSION",
      "IMMUTABLE_WITH_EXCLUSION"
    ], var.image_tag_mutability)

    error_message = "Invalid ECR image tag mutability setting."
  }
}

variable "scan_on_push" {
  description = "Whether ECR scans images after they are pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type used by the ECR repository."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be AES256 or KMS."
  }
}
