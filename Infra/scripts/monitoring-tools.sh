#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y wget tar

# Install Prometheus
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.53.1/prometheus-2.53.1.linux-amd64.tar.gz
tar -xvf prometheus-2.53.1.linux-amd64.tar.gz
rm -rf prometheus-2.53.1.linux-amd64.tar.gz
sudo mv prometheus-2.53.1.linux-amd64 prometheus
cd /opt/prometheus
sudo chmod +x prometheus
./prometheus --config.file=prometheus.yml &
#can be accessed at port 9090



# Install Blackbox Exporter
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
tar -xvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
rm -rf blackbox_exporter-0.25.0.linux-amd64.tar.gz
sudo mv blackbox_exporter-0.25.0.linux-amd64 blackbox_exporter
cd /opt/blackbox_exporter
sudo chmod +x blackbox_exporter
./blackbox_exporter &
#can be accessed at port 9115


# Install Alertmanager
wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
tar -xvf alertmanager-0.27.0.linux-amd64.tar.gz
rm -rf alertmanager-0.27.0.linux-amd64.tar.gz
sudo mv alertmanager-0.27.0.linux-amd64 alertmanager
cd /opt/alertmanager
sudo chmod +x alertmanager
./alertmanager --config.file=alertmanager.yml &
#can be accessed at port 9093
