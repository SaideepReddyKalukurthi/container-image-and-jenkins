variable "project_id" {
    type = string
    description = "(optional) describe your variable"
}

variable "region_name" {
    type = string
    description = "(optional) describe your variable"
}


variable "jenkins_instance_metadata" {
  description = "Additional metadata to pass to the Jenkins master instance"
  type        = map(string)
  default     = {}
}

variable "jenkins_instance_zone" {
  description = "The zone to deploy the Jenkins VM in"
  default     = "us-central1-a"
}

variable "jenkins_workers_zone" {
  description = "The name of the zone into which to deploy Jenkins workers"
  default     = "us-central1-b"
}

variable "jenkins_network_project_id" {
    type = string
    description = "(optional) describe your variable"
    default = ""
}

variable "network" {
    type = string
    description = "(optional) describe your variable"
    default = "sai"
}