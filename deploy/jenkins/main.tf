


# module "jenkins" {
#   source  = "terraform-google-modules/jenkins/google"
#   version = "1.1.0"
#   # insert the 8 required variables here
#   jenkins_instance_network = "sai"
#   jenkins_instance_subnetwork = "demo-sub"
#   jenkins_instance_zone = "${var.region_name}-a"
#   jenkins_workers_network = data.google_compute_network.my-network.self_link
#   jenkins_workers_project_id = var.project_id
#   jenkins_workers_region = var.region_name
#   project_id = var.project_id
#   region = var.region_name
#   jenkins_boot_disk_source_image_project = "bitnami-launchpad"
# }

provider "google" {
    project = var.project_id
    region = var.region_name
}

locals {
  worker_network_project_id = coalesce(var.jenkins_network_project_id, var.project_id)
}

resource "google_project_service" "cloudresourcemanager" {
  project            = var.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = "false"
}

resource "google_project_service" "iam" {
  project            = google_project_service.cloudresourcemanager.project
  service            = "iam.googleapis.com"
  disable_on_destroy = "false"
}



resource "google_storage_bucket" "artifacts" {
  name          = "${var.project_id}-jenkins-artifacts"
  project       = var.project_id
  force_destroy = true
  location = "us-central1"
}

resource "google_compute_firewall" "jenkins_agent_ssh_from_instance" {
  name    = "jenkins-agent-ssh-access"
  network = var.network
  project = local.worker_network_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["jenkins"]
  target_tags = ["jenkins-agent"]
}

resource "google_compute_firewall" "jenkins_agent_discovery_from_agent" {
  name    = "jenkins-agent-udp-discovery"
  network = var.network
  project = local.worker_network_project_id

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_tags = ["jenkins", "jenkins-agent"]
  target_tags = ["jenkins", "jenkins-agent"]
}

module "jenkins-gce" {
  source                                         = "terraform-google-modules/jenkins/google"
  project_id                                     = google_project_service.iam.project
  region                                         = var.region_name
  gcs_bucket                                     = google_storage_bucket.artifacts.name
  jenkins_instance_zone                          = "${var.region_name}-a"
  jenkins_instance_network                       = data.google_compute_network.my-network.name
  jenkins_instance_subnetwork                    = data.google_compute_network.my-network.subnetworks_self_links[0]
  jenkins_instance_additional_metadata           = var.jenkins_instance_metadata
  jenkins_workers_region                         = var.region_name
  jenkins_workers_project_id                     = google_project_service.iam.project
  jenkins_workers_zone                           = var.jenkins_workers_zone
  jenkins_workers_machine_type                   = "n1-standard-1"
  jenkins_workers_boot_disk_type                 = "pd-ssd"
  jenkins_workers_network                        = data.google_compute_network.my-network.self_link
  jenkins_workers_network_tags                   = ["jenkins-agent"]
  jenkins_workers_boot_disk_source_image         = data.google_compute_image.jenkins_agent.name
  jenkins_workers_boot_disk_source_image_project = var.project_id

  jenkins_jobs = [
    {
      name     = "testjob"
      manifest = data.template_file.example_job.rendered
    },
  ]
}
