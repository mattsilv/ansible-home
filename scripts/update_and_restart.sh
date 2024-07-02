#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo systemctl restart docker
sudo systemctl restart prometheus
sudo systemctl restart grafana-server