# Ubuntu Server Management Guide

## Table of Contents

1. [Configuration Management with Ansible](#configuration-management-with-ansible)
2. [Version Control with GitHub](#version-control-with-github)
3. [Secure Remote Access with SSH](#secure-remote-access-with-ssh)
4. [Web UI for Management](#web-ui-for-management)
5. [Continuous Deployment with GitHub Actions](#continuous-deployment-with-github-actions)
6. [Containerization with Docker](#containerization-with-docker)
7. [Monitoring with Prometheus and Grafana](#monitoring-with-prometheus-and-grafana)
8. [Custom Scripting](#custom-scripting)
9. [Firewall Configuration](#firewall-configuration)

## Configuration Management with Ansible

Install Ansible on your MacOS laptop:

```sh
brew install ansible
```

Create a directory structure in your private GitHub repository:

```
.
├── ansible.cfg
├── inventory
│   └── hosts
├── playbooks
│   ├── common.yml
│   ├── server1.yml
│   └── server2.yml
└── roles
    ├── common
    ├── server1
    └── server2
```

Optionally, you can run this shell command to create the files/folders:

```sh
mkdir -p inventory playbooks roles/{common,server1,server2} && touch ansible.cfg inventory/hosts playbooks/{common.yml,server1.yml,server2.yml}
```

## Version Control with GitHub

Store all your Ansible playbooks, roles, and custom scripts in your private GitHub repository. This ensures version control and easy collaboration.

## Secure Remote Access with SSH

Generate SSH keys on your MacOS laptop:

```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Copy the public key to both servers:

```sh
ssh-copy-id user@server1
ssh-copy-id user@server2
```

Disable password authentication in `/etc/ssh/sshd_config` on your Linux servers:

```sh
sudo nano /etc/ssh/sshd_config
```

```sh
PasswordAuthentication no
```

## Web UI for Management

**File to edit: `playbooks/common.yml`**

```yaml
- name: Install Cockpit
  apt:
    name: cockpit
    state: present

- name: Enable Cockpit service
  systemd:
    name: cockpit.socket
    enabled: yes
    state: started
```

Access Cockpit via `https://<server-ip>:9090`

## Continuous Deployment with GitHub Actions

Create a `.github/workflows/deploy.yml` file in your repository:

**File to edit: `.github/workflows/deploy.yml`**

```yaml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Ansible
        run: sudo apt-get update && sudo apt-get install -y ansible
      - name: Run Ansible playbook
        env:
          PRIVATE_KEY: ${{ secrets.SERVER_SSH_KEY }}
        run: |
          echo "$PRIVATE_KEY" > private_key && chmod 600 private_key
          ansible-playbook -i inventory/hosts playbooks/common.yml --private-key private_key
```

Add your SSH private key to GitHub Secrets as `SERVER_SSH_KEY`.

## Containerization with Docker

Include Docker installation and management in your Ansible playbooks:

**File to edit: `playbooks/common.yml`**

```yaml
- name: Install Docker
  apt:
    name: docker.io
    state: present

- name: Start Docker service
  systemd:
    name: docker
    state: started
    enabled: yes

- name: Pull and run Docker containers
  docker_container:
    name: "{{ item.name }}"
    image: "{{ item.image }}"
    state: started
  loop:
    - { name: container1, image: image1:latest }
    - { name: container2, image: image2:latest }
```

## Monitoring with Prometheus and Grafana

Set up Prometheus and Grafana using Ansible:

**File to edit: `playbooks/common.yml`**

```yaml
- name: Install Prometheus
  apt:
    name: prometheus
    state: present

- name: Install Grafana
  apt:
    deb: https://dl.grafana.com/oss/release/grafana_7.5.7_amd64.deb

- name: Start Prometheus and Grafana services
  systemd:
    name: "{{ item }}"
    state: started
    enabled: yes
  loop:
    - prometheus
    - grafana-server
```

## Custom Scripting

Create a `scripts` directory in your GitHub repo for Bash/Python scripts. For example, a script to update and restart services:

**File to edit: `scripts/update_and_restart.sh`**

```bash
#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo systemctl restart docker
sudo systemctl restart prometheus
sudo systemctl restart grafana-server
```

Call these scripts from your Ansible playbooks as needed.

## Firewall Configuration

Configure UFW (Uncomplicated Firewall) using Ansible:

**File to edit: `playbooks/common.yml`**

```yaml
- name: Install UFW
  apt:
    name: ufw
    state: present

- name: Allow SSH
  ufw:
    rule: allow
    port: "22"

- name: Allow Cockpit
  ufw:
    rule: allow
    port: "9090"

- name: Enable UFW
  ufw:
    state: enabled
```

## Deploying Changes

1. Update your Ansible playbooks or scripts in your local Git repository.
2. Commit and push changes to GitHub:
   ```sh
   git add .
   git commit -m "Update server configurations"
   git push origin main
   ```
3. GitHub Actions will automatically deploy the changes to your servers.
