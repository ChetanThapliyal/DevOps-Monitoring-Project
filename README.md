# DevOps Monitoring with Prometheus

## Overview

This project demonstrates the implementation of a comprehensive monitoring system using Prometheus, Node Exporter, Blackbox Exporter, and Alertmanager. The infrastructure is provisioned using Terraform, ensuring a consistent and repeatable setup.

![Monitoring System](/Architecture/monitoring.png)

## Features

- **Comprehensive Monitoring:** Collects and visualizes metrics from various sources, including system resources and application-specific metrics.
- **Real-Time Alerts:** Configurable alerting system to notify users of potential issues, allowing for quick resolution.
- **Scalable Architecture:** Easily extendable to monitor additional services and resources.
- **Infrastructure as Code:** Terraform scripts manage and provision infrastructure, ensuring a consistent environment.

## Project Structure

```bash
.
├── config
│   ├── alertmanager.yml
│   ├── alert_rules.yml
│   └── prometheus.yaml
├── Infra
│   ├── main.tf
│   ├── providers.tf
│   ├── scripts
│   │   ├── config
│   │   ├── monitoring-tools.sh
│   │   └── node-exporter.sh
│   ├── secrets
│   │   └── credentials.json
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── variables.tf
├── LICENSE
├── README.md
└── src
    └── Boardgame
```

## Getting Started

### Prerequisites

- GCP account and gcloud cli configured
- Terraform with GCP
- Basic knowledge of Prometheus

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ChetanThapliyal/real-time-devops-monitoring.git
   cd real-time-devops-monitoring
   ```

2. **Set Up Environment:**
   Configure your environment variables in the `variables.tf` and `terraform.tfvars` files as needed:
   ```bash
    gcp_svc_key = "./path/to/gcp_service_key"
    gcp_project_id = Your GCP Project ID
    gcp_region = Region
    gcp_zone = Zone
    gcp_service_account_email = Your Service Account Email
    gcp_network_interface_subnetworks = "projects/gcp_project_id/regions/Region/subnetworks/NetworkName"  
   ```

3. **Deploy the Infrastructure with Terraform:**
   Navigate to the `Infra` directory and apply the Terraform configuration:
   ```bash
   cd Infra
   terraform init
   terraform apply
   ```
   - Two VM's will be created 'monitoring' and 'NodeExporter'

4. **Configure Monitoring Tools:**
    - SSH into monitoring VM and replace prometheus.yml in prometheus installation (from config folder) and add `alert_rules.yml` in same folder:
    ```bash
    gcloud compute ssh monitoring
    cd /opt/prometheus
    vi prometheus.yml
    vi alert_rules.yml
    ```
    - Also replace `alertmanager.yml` file (from config folder) in 
    ```bash
    cd /opt/alertmanager
    vi alertmanager.yml
    ```

5. Access Prometheus at port `9090`

## Components

1. **Prometheus:** Central component for data collection and querying.
2. **Node Exporter:** Collects hardware and OS metrics from the host.
3. **Blackbox Exporter:** Probes endpoints over HTTP, HTTPS, DNS, TCP, ICMP, etc.
4. **Alertmanager:** Manages alerts sent by client applications such as the Prometheus server.

## Usage

### Adding a Target

To monitor a new service, add a new job to the `prometheus.yml` configuration file:

```yaml
- job_name: 'new_service'
  static_configs:
    - targets: ['localhost:8080']
```

### Configuring Alerts

Alerts are defined in the `alert_rules.yml` file. Here's an example of a high CPU load alert:

```yaml
groups:
- name: example
  rules:
  - alert: HighCpuLoad
    expr: sum(rate(cpu_usage_seconds_total[1m])) by (instance) > 0.9
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High CPU load on {{ $labels.instance }}"
      description: "CPU load is > 90% for more than 5 minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
```


## Contributing

We welcome contributions to enhance this project! Please fork the repository and submit a pull request with your changes.