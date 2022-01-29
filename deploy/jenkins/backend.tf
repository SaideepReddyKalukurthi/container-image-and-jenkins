data "google_compute_network" "my-network" {
  name = "sai"
}

data "google_compute_image" "jenkins_agent" {
  project = google_project_service.cloudresourcemanager.project
  family  = "jenkins-agent"
}


data "local_file" "example_job_template" {
  filename = "${path.module}/templates/example_job.xml.tpl"
}

data "template_file" "example_job" {
  template = data.local_file.example_job_template.content

  vars = {
    project_id            = var.project_id
    build_artifact_bucket = google_storage_bucket.artifacts.url
  }
}
