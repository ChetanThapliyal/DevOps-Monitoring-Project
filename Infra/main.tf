# Network creation
#-----------------#
resource "google_compute_network" "dev-cicd-vpc" {
    auto_create_subnetworks = true
    description             = "VPC for secure CICD pipeline."
    mtu                     = 1460
    name                    = "dev-cicd-vpc"
    project                 = var.gcp_project_id
    routing_mode            = "REGIONAL"
}

# Firewall Rules
#-----------------#

## Custom firewall rules
resource "google_compute_firewall" "dev-cicd-vpc-allow-custom" {
    name                    = "dev-cicd-vpc-allow-custom"
    project                 = var.gcp_project_id
    network                 = google_compute_network.dev-cicd-vpc.name
    description             = "Allows connection from any source to any instance on the network using custom protocols."
    direction               = "INGRESS"
    priority                = 65534
    source_ranges           = ["0.0.0.0/0"] 
    allow {
        protocol = "tcp" 
        ports    = ["80", "443", "465", "6443", "3000-10000", "30000-32767"]
    }
}

## ICMP
resource "google_compute_firewall" "dev-cicd-vpc-allow-icmp" {
    network     = google_compute_network.dev-cicd-vpc.name
    project     = var.gcp_project_id
    direction   = "INGRESS"
    priority    = 65534
    source_ranges = ["0.0.0.0/0"]
    name        = "dev-cicd-vpc-allow-icmp" 
    description = "Allows ICMP connections from any source to any instance on the network."
    allow {
        protocol = "icmp"
    }
}

## SSH
resource "google_compute_firewall" "dev-cicd-vpc-allow-ssh" {
    network     = google_compute_network.dev-cicd-vpc.name
    project     = var.gcp_project_id
    direction   = "INGRESS"
    priority    = 65534
    source_ranges = ["0.0.0.0/0"]
    name        = "dev-cicd-vpc-allow-ssh"
    description = "Allows TCP connections from any source to any instance on the network using port 22."
    allow {
        protocol = "tcp" 
        ports    = ["22"]
    }
}

#VM creation
#-----------------#

# Monitoring VM
#---------------#
resource "google_compute_instance" "prometheus" {
    name = "monitoring"
    machine_type = "e2-medium"
    tags = ["http-server", "https-server", "lb-health-check"]
    zone = "asia-south1-c"
    
    
    boot_disk {
        auto_delete = true
        device_name = "monitoring-nodes"

        initialize_params {
        image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240307b"
        size  = 20
        type  = "pd-balanced"
        }

        mode = "READ_WRITE"
    }

    metadata = {
        startup-script = file("./scripts/monitoring-tools.sh")
    }

    can_ip_forward      = false
    deletion_protection = false
    enable_display      = false

    labels = {
        goog-ec-src = "vm_add-tf"
        sonarqube   = ""
    }

    network_interface {
        access_config {
        network_tier = "STANDARD"
        }

        queue_count = 0
        stack_type  = "IPV4_ONLY"
        network     = google_compute_network.dev-cicd-vpc.name
    }

    scheduling {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
        preemptible         = false
        provisioning_model  = "STANDARD"
    }

    service_account {
        email  = var.gcp_service_account_email
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }

    shielded_instance_config {
        enable_integrity_monitoring = true
        enable_secure_boot          = false
        enable_vtpm                 = true
    }
}
#Access SonarQube by opening a web browser and navigating to http://VmIP:9000

# Node Exporters VM
#---------------#
resource "google_compute_instance" "nodeexporter" {
    boot_disk {
        auto_delete = true
        device_name = "node-exporter"

        initialize_params {
        image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240307b"
        size  = 20
        type  = "pd-balanced"
        }

        mode = "READ_WRITE"
    }

    can_ip_forward      = false
    deletion_protection = false
    enable_display      = false

    labels = {
        goog-ec-src = "vm_add-tf"
        nexus       = ""
    }

    machine_type = "e2-medium"

    metadata = {
        startup-script = file("./scripts/node-exporter.sh")
    }

    name = "nodeexporter"

    network_interface {
        access_config {
        network_tier = "STANDARD"
        }

        queue_count = 0
        stack_type  = "IPV4_ONLY"
        network     = google_compute_network.dev-cicd-vpc.name
    }

    scheduling {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
        preemptible         = false
        provisioning_model  = "STANDARD"
    }

    service_account {
        email  = var.gcp_service_account_email
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }

    shielded_instance_config {
        enable_integrity_monitoring = true
        enable_secure_boot          = false
        enable_vtpm                 = true
    }

    tags = ["http-server", "https-server", "lb-health-check"]
    zone = "asia-south1-c"
}
# Nexus will be accessible on your host machine at http://IP:8081.