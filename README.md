
# 🐗 Locust AWS Performance Testing with Terraform

This quick-start Terraform project deploys a **Locust Master** and two **Locust Worker** nodes on AWS using `t4g.micro` instances. It’s designed for fast, disposable performance testing with your own pre-built Docker image.

> ⚠️ Note: The Docker image was built on a Mac, so ARM-based EC2 instances (`t4g.micro`) are used to ensure compatibility.

---

## 🚀 What It Does

- Spins up:
  - 1 Locust Master instance (port `8089` for UI, `5557-5558` for master-worker comms)
  - 2 Locust Worker instances
- Uses a shared Security Group with open access to required ports
- Automatically installs Docker and pulls your Locust Docker image
- Runs the master and worker containers using your pre-defined `locustfile.py`

---

## 📁 File Overview

- `main.tf` – Terraform config for provisioning AWS EC2 instances and networking.

---

## 🧰 Requirements

- [Terraform](https://www.terraform.io/downloads)
- AWS credentials configured (`~/.aws/credentials` or environment variables)
- A valid AWS key pair (update `key_name` in `main.tf`)
- Docker image published to Docker Hub or another accessible registry

---

## 🔧 Configuration

Before running Terraform:

1. **Update Docker Info**  
   Replace:
   ```hcl
   docker login -u loginname -p dockerpat
   docker pull name/project:image
   with your actual Docker Hub credentials and image.
Set Your Key Pair
Replace:
hcl
key_name = ""
with the name of your AWS EC2 key pair.

▶️ How to Use
bash
terraform init
terraform apply
Once deployed, open the Locust UI:
http://<locust_master_public_ip>:8089
Use the interface to configure your test and unleash the locust swarm.

🧼 Cleanup
bash
terraform destroy
Poof. Everything’s gone. Just the way you like your temporary test infrastructure.

💡
Notes
Security group is wide open (ports 22, 8089, 5557, 5558). Lock it down before production.
If you’re using a private Docker repo, ensure your login credentials are valid.
ARM instances are budget-friendly and Mac-compatible. You’re welcome. 


‍💻 Author Adam Satterfield
Built with 💻 on a Mac and deployed using Terraform and AWS.

