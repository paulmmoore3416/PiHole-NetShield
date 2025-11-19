# PiHole-NetShield

[![GitHub stars](https://img.shields.io/github/stars/paulmmoore3416/PiHole-NetShield?style=social)](https://github.com/paulmmoore3416/PiHole-NetShield)
[![GitHub forks](https://img.shields.io/github/forks/paulmmoore3416/PiHole-NetShield?style=social)](https://github.com/paulmmoore3416/PiHole-NetShield)
[![License](https://img.shields.io/github/license/paulmmoore3416/PiHole-NetShield)](https://github.com/paulmmoore3416/PiHole-NetShield/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/paulmmoore3416/PiHole-NetShield)](https://github.com/paulmmoore3416/PiHole-NetShield/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/paulmmoore3416/PiHole-NetShield)](https://github.com/paulmmoore3416/PiHole-NetShield/pulls)

[![Ansible](https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)
[![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-A22846?style=for-the-badge&logo=raspberry-pi&logoColor=white)](https://www.raspberrypi.org/)
[![Networking](https://img.shields.io/badge/Networking-007ACC?style=for-the-badge&logo=networking&logoColor=white)](https://en.wikipedia.org/wiki/Computer_network)
[![DNS](https://img.shields.io/badge/DNS-007ACC?style=for-the-badge&logo=dns&logoColor=white)](https://en.wikipedia.org/wiki/Domain_Name_System)
[![Security](https://img.shields.io/badge/Security-000000?style=for-the-badge&logo=security&logoColor=white)](https://en.wikipedia.org/wiki/Computer_security)

## Overview

PiHole-NetShield is a comprehensive Raspberry Pi-hole project designed to block ads and enhance network performance. This project uses Ansible for automated setup and includes 8 custom optimizations for superior functionality. The system runs continuously in the background and starts automatically on boot.

## Features

- **Ad Blocking**: Efficiently blocks ads and trackers across your network
- **Network Enhancement**: Optimizes DNS resolution and network traffic
- **Automated Setup**: Ansible playbooks for easy deployment
- **Background Operation**: Runs as a systemd service, starting on boot
- **8 Custom Enhancements**:
  1. Custom Blocklist Manager
  2. Performance Monitoring
  3. Auto Update Script
  4. Backup and Restore
  5. Network Traffic Analyzer
  6. IoT Device Isolation
  7. VPN Integration
  8. Log Analysis Tool

## Skills Demonstrated

- **Ansible**: Automation and configuration management
- **Bash Scripting**: System administration and custom scripts
- **Linux System Administration**: Service management, networking, security
- **Networking**: DNS configuration, firewall rules, traffic analysis
- **Raspberry Pi**: Embedded Linux deployment and optimization
- **Security**: Firewall configuration, access control, monitoring
- **DevOps**: CI/CD workflows, version control, documentation

## Prerequisites

- Raspberry Pi (3B+ or newer recommended)
- Raspberry Pi OS Lite
- Ansible installed on control machine
- SSH access to Raspberry Pi

## Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/paulmmoore3416/PiHole-NetShield.git
   cd PiHole-NetShield
   ```

2. Update the inventory file with your Raspberry Pi details.

3. Run the Ansible playbook:

   ```bash
   ansible-playbook -i inventory.ini ansible/playbook.yml
   ```

   ## Web GUI

   PiHole-NetShield provides a simple web GUI for common tasks (start/stop, updates, backups, add blocklists). The GUI runs a small Flask app and is managed by systemd.

   1. Secure the GUI by creating an Ansible Vault file for secrets (use the example in `ansible/secrets-example.yml`). Add `gui_token` to the vault and/or configure your reverse proxy.

   2. Run the role:

      ```bash
      ansible-playbook -i inventory.example.ini --ask-vault-password ansible/playbook.yml
      ```

   3. Access the UI on the configured port (default 8080):

      http://raspberrypi:8080

   4. Use the token (if configured) by sending Authorization header: `Authorization: Bearer <your_token>` or set it in the env via Ansible.

   Security note: This GUI can execute commands with system privileges and is intended for local network-managed devices only; do not expose without robust authentication and TLS.

## Project Structure

```
PiHole-NetShield/
├── ansible/
│   ├── playbook.yml
│   └── roles/
│       ├── pihole/
│       │   ├── tasks/
│       │   ├── templates/
│       │   └── vars/
│       └── enhancements/
│           ├── tasks/
│           ├── templates/
│           └── vars/
├── scripts/
├── docs/
├── .github/
│   └── workflows/
├── README.md
└── LICENSE
```

## Enhancements

### 1. Custom Blocklist Manager

Manages additional custom blocklists for enhanced ad blocking.

### 2. Performance Monitoring

Monitors Pi-hole performance metrics and system resources.

### 3. Auto Update Script

Automatically updates Pi-hole and system packages.

### 4. Backup and Restore

Automated backup and restore functionality for configurations.

### 5. Network Traffic Analyzer

Analyzes network traffic patterns and provides insights.

### 6. IoT Device Isolation

Isolates IoT devices for security and performance.

### 7. VPN Integration

Integrates VPN for secure remote access.

### 8. Log Analysis Tool

Analyzes logs for troubleshooting and optimization.

## Contributing

Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Pi-hole](https://pi-hole.net/) for the core ad-blocking functionality
- [Ansible](https://www.ansible.com/) for automation
- Raspberry Pi community for hardware support
