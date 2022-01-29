variable "project_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "region_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "image_link" {
    type = string
    description = "(optional) describe your variable"
}

variable "service_account" {
    type = object({
    email  = string
    scopes = set(string)
  })
    description = "(optional) describe your variable"
}
