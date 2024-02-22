variable tags {
  type = map(string)
  
}

variable bucket_name {
  type = string
}

variable env {
  type = string
  
}

variable kms_key_arn {
  type        = string
  description = "The KMS key for lambda env encryption"
}

variable "region_shorthand" {
   type        = string
   default     = ""
   description = "region shorthand differentiate regions on global resources"
}

