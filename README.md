<div align="center">

# 🚀 Gitmate Infrastructure

### Production-grade AWS infrastructure-as-code for the Gitmate platform

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)
[![AWS](https://img.shields.io/badge/AWS-ap--south--1-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)]()
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)]()

*A two-tier VPC deployment with isolated frontend/backend compute, NAT-routed private networking, and least-privilege security groups.*

</div>

---

## 📖 Table of Contents

- [Architecture](#-architecture)
- [What Gets Built](#-what-gets-built)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Input Variables](#-input-variables)
- [Outputs](#-outputs)
- [Security Notes](#-security-notes)
- [Roadmap](#-roadmap)

---

## 🏗 Architecture

GitMate runs on a classic two-tier VPC split across a **public** subnet (internet-facing) and a **private** subnet (internally routed), connected through a NAT Gateway.

```
                                            🌐 INTERNET  
                                                |
                                                v
                                    +---------------------+
                                    |   INTERNET GATEWAY   |
                                    +----------+----------+
                                                |
                                                v
                    +-------------------------------------------------------+
                    |                    PUBLIC SUBNET                      |
                    |                                                       |
                    |   +-----------------------------------------------+   |
                    |   |                FRONTEND EC2                   |   |
                    |   |                                               |   |
                    |   |   - Elastic IP attached                       |   |
                    |   |   - Ports 80, 443, 22 open                    |   |
                    |   +-----------------------+-----------------------+   |
                    |                           |                           |
                    |                           v                           |
                    |                  +----------------+                   |
                    |                  |  NAT GATEWAY   |                   |
                    |                  +--------+-------+                   |
                    |                           |                           |
                    +---------------------------+---------------------------+
                                                |
                                                v
                    +-------------------------------------------------------+
                    |                   PRIVATE SUBNET                      |
                    |                                                       |
                    |   +-----------------------------------------------+   |
                    |   |                 BACKEND EC2                   |   |
                    |   |                                               |   |
                    |   |   - Private IP: 10.0.2.10                     |   |
                    |   |   - No public IP                              |   |
                    |   |   - Port 5000: application                    |   |
                    |   |   - Port 22: SSH                              |   |
                    |   +-----------------------------------------------+   |
                    |                                                       |
                    +-------------------------------------------------------+
```

**Traffic flow:**
- **Inbound (public):** Internet → IGW → Frontend EC2 (HTTP/HTTPS/SSH)
- **Internal:** Frontend EC2 → Backend EC2 (port `5000`, SG-to-SG only)
- **Outbound (private):** Backend EC2 → NAT Gateway → IGW → Internet

---

## 📦 What Gets Built

<table>
<tr><td width="140"><b>🌐 Networking</b></td><td>VPC · Internet Gateway · NAT Gateway · Public &amp; Private Subnets · Route Tables + Associations</td></tr>
<tr><td><b>🔒 Security</b></td><td>Frontend SG (HTTP/HTTPS/SSH) · Backend SG (app port + SSH, frontend-only)</td></tr>
<tr><td><b>💻 Compute</b></td><td>Frontend EC2 (public, Elastic IP) · Backend EC2 (private, static IP)</td></tr>
<tr><td><b>📌 Addressing</b></td><td>NAT Gateway EIP · Frontend EIP</td></tr>
</table>

---

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| 🧰 Terraform | `>= 1.3` — [install here](https://developer.hashicorp.com/terraform/downloads) |
| ☁️ AWS Account | Named CLI profile `gitmate` configured, or update `provider.tf` |
| 🔑 EC2 Key Pair | Must already exist in the target region, matching `key_name` |
| 📁 Local secrets | See below |

<details>
<summary><b>🔐 Required local files (click to expand)</b></summary>

| File | Purpose |
|---|---|
| `keys/frontend_keys.txt` | Deploy/SSH key used by the frontend provisioning script |
| `keys/gitmate.pem` | SSH key the frontend uses to reach the backend |
| `keys/backend_keys.txt` | Deploy/SSH key used by the backend provisioning script |
| `keys/backend_env.txt` | Environment config injected into the backend |

> ⚠️ **These contain secrets.** Keep `keys/` out of version control — add it to `.gitignore` immediately if it isn't already there.

</details>

---

## 📂 Project Structure

```
gitmate-infra/
├── 📄 main.tf              # Core infrastructure resources
├── 📄 variables.tf         # Input variable declarations
├── 📄 outputs.tf           # Output values
├── 📄 provider.tf          # AWS provider configuration
├── 📄 terraform.tfvars     # Environment-specific values
├── 📁 scripts/
│   ├── frontend.sh         # Frontend user-data / bootstrap script
│   └── backend.sh          # Backend user-data / bootstrap script
└── 📁 keys/                # 🔒 Secrets — git-ignored
```

---

## ⚡ Quick Start

```bash
# 1. Clone and enter the project
git clone <repo-url> && cd gitmate-infra

# 2. Add required secrets to keys/ (see Prerequisites)

# 3. Initialize Terraform
terraform init

# 4. Preview the plan
terraform plan

# 5. Apply 🚀
terraform apply

# 🧹 Tear it all down when done
terraform destroy
```

---

## 🔧 Input Variables

<details>
<summary><b>Show all variables</b></summary>

| Variable | Description |
|---|---|
| `aws_region` | AWS region to deploy into |
| `vpc_cidr` | CIDR block for the VPC |
| `vpc_tag_name` | Name tag for the VPC |
| `public_subnet_cidr` | CIDR block for the public subnet |
| `public_subnet_tag_name` | Name tag for the public subnet |
| `private_subnet_cidr` | CIDR block for the private subnet |
| `private_subnet_tag_name` | Name tag for the private subnet |
| `igw_tag_name` | Name tag for the Internet Gateway |
| `public_cidr_ipv4` | IPv4 CIDR for public ingress/egress rules |
| `public_cidr_ipv6` | IPv6 CIDR reserved for public rules |
| `frontend_sg_tag_name` | Name tag for the frontend security group |
| `backend_sg_tag_name` | Name tag for the backend security group |
| `public_rt_tag_name` | Name tag for the public route table |
| `private_rt_tag_name` | Name tag for the private route table |
| `nat_tag_name` | Name tag for the NAT Gateway |
| `nat_eip_tag_name` | Name tag for the NAT Gateway's EIP |
| `frontend_ami` | AMI ID for the frontend EC2 instance |
| `frontend_instance_type` | Instance type for the frontend EC2 instance |
| `frontend_tag_name` | Name tag for the frontend EC2 instance |
| `frontend_eip_tag_name` | Name tag for the frontend Elastic IP |
| `backend_ami` | AMI ID for the backend EC2 instance |
| `backend_instance_type` | Instance type for the backend EC2 instance |
| `backend_tag_name` | Name tag for the backend EC2 instance |
| `backend_private_ip` | Static private IP for the backend instance |
| `key_name` | EC2 key pair used for SSH access |

</details>

---

## 📤 Outputs

<details>
<summary><b>Show all outputs</b></summary>

| Output | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `public_subnet_id` | ID of the public subnet |
| `private_subnet_id` | ID of the private subnet |
| `frontend_security_group_id` | ID of the frontend security group |
| `backend_security_group_id` | ID of the backend security group |
| `nat_gateway_id` | ID of the NAT Gateway |
| `nat_eip` | Elastic IP of the NAT Gateway |
| `frontend_instance_id` | ID of the frontend EC2 instance |
| `frontend_public_ip` | Public IP of the frontend EC2 instance |
| `frontend_public_dns` | Public DNS of the frontend EC2 instance |
| `backend_instance_id` | ID of the backend EC2 instance |
| `backend_private_ip` | Private IP of the backend EC2 instance |
| `frontend_eip` | Elastic IP resource attached to the frontend |

</details>

---

## 🛡 Security Notes

> 🟢 **Good:** Backend SG only trusts the Frontend SG (`referenced_security_group_id`) — no direct public exposure.

> 🟡 **Review:** Frontend SG opens ports `80`, `443`, and `22` to `public_cidr_ipv4`. Scope SSH down to trusted IP ranges (e.g. an office/VPN CIDR) before running this in production.

> 🟡 **Review:** Secrets are currently read from plaintext files in `keys/` and injected via `user_data`. Consider migrating to **AWS Secrets Manager** or **SSM Parameter Store**.

> 🔵 **Tip:** Enable **VPC Flow Logs** for network visibility and auditing.

---

## 🗺 Roadmap

- [ ] Move secrets out of local files into AWS Secrets Manager
- [ ] Restrict SSH ingress to a fixed CIDR / bastion host
- [ ] Add CloudWatch alarms + basic monitoring
- [ ] Parameterize AMIs per environment (dev/staging/prod)
- [ ] Add Terraform remote state (S3 + DynamoDB locking)

---

<div align="center">

Built by **Abubakar Dahir Hassan** for **Gitmate** · Managed with Terraform

</div>