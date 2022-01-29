provider "google" {
    project = var.project_id
    region = var.region_name
}

module "gce-container" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image = "gcr.io/learning-25/sai@sha256:46b1ecaf18cdf81a17bf9bb8b1b84d2d0a0573ecdcf2755ce65deb4adae22d35"

  }
}

resource "random_shuffle" "zone" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

module "template" {
    source = "terraform-google-modules/vm/google//modules/instance_template"
    name_prefix = "reddy"
    network = "sai"
    subnetwork = "demo-sub"
    source_image = module.gce-container.source_image
    tags = ["container-vm-example", "http-server" ]
    metadata = {
      gce-container-declaration = module.gce-container.metadata_value
    }
    labels = {
      container-vm = module.gce-container.vm_container_label
    }
    access_config = [ {
      nat_ip = ""
      network_tier = "STANDARD"
    } ]
    service_account = var.service_account
}


module "instance" {
    source  = "terraform-google-modules/vm/google//modules/compute_instance"
    instance_template = module.template.self_link
    network = "sai"
    region = "us-central1"
    subnetwork = "demo-sub"
    access_config = [ {
      nat_ip = ""
      network_tier = "STANDARD"
    } ]
    
      
}
