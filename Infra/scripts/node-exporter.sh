#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y wget tar

# Install Node Exporter
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz
rm -rf node_exporter-1.8.2.linux-amd64.tar.gz
sudo mv node_exporter-1.8.2.linux-amd64 node_exporter
cd /opt/node_exporter
sudo chmod +x node_exporter
./node_exporter &
#can be accessed at port 9100

# Install OpenJDK 17 JRE Headless
sudo apt install openjdk-17-jre-headless -y

# Install Maven
sudo apt install maven -y
sudo apt-get update

#clone project
cd /opt
git clone https://github.com/ChetanThapliyal/real-time-devops-monitoring.git
cd /opt/real-time-devops-monitoring/src/Boardgame
sudo mvn package
cd target/
java -jar database_service_project-*.jar &  #port 8080







