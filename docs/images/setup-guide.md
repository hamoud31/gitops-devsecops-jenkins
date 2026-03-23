# 🛠️ Setup Guide

### DevSecOps & GitOps Platform (Aligned with Jenkins Pipelines)

This guide explains how to deploy and operate the full platform using:

* CI/CD with Jenkins
* Infrastructure as Code with Terraform
* Container security with Trivy
* Code quality with SonarQube
* GitOps deployment with ArgoCD
* Kubernetes orchestration with Kubernetes (EKS)
* Monitoring with Prometheus & Grafana
* Cloud provider: Amazon Web Services

---

# 🚀 Before You Start

Make sure you have:

* AWS account
* IAM user with programmatic access
* GitHub repository access
* SSH access to EC2 instances
* Architecture diagram in `/docs/images/architecture.png`

---

# 🏭 Production Notes

* Use HTTPS (TLS) for Jenkins, SonarQube, and Nexus
* Use a domain name with DNS (Route53 recommended)
* Use IAM Roles instead of static AWS credentials
* Store secrets in AWS Secrets Manager or Vault
* Enable centralized logging (CloudWatch / ELK / Loki)

---

# 🏗️ 1. Infrastructure Overview

The platform uses **4 EC2 instances**:

| Instance  | Purpose                          |
| --------- | -------------------------------- |
| Jenkins   | CI/CD pipelines                  |
| Nexus     | Artifact repository              |
| SonarQube | Code analysis                    |
| Jump Host | Kubernetes & platform management |

All services run in Docker containers.

---

# ⚙️ 2. Base Installation (All EC2)

```bash
sudo apt update -y
sudo apt install -y docker.io git unzip
sudo systemctl enable docker
sudo systemctl start docker
```

### Additional tools (Jenkins & Jump Host)

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install

# Terraform
wget https://releases.hashicorp.com/terraform/<version>/terraform_<version>_linux_amd64.zip
unzip terraform_*.zip
sudo mv terraform /usr/local/bin/

# Trivy
sudo apt install -y trivy
```

---

# 📦 3. Nexus & SonarQube Setup

## Nexus

```bash
docker run -d --name nexus -p 8081:8081 sonatype/nexus3
```

## SonarQube

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts
```

### Configure:

* Create project: `bankapp`
* Generate token for Jenkins

---

# 🔧 4. Jenkins Configuration

## Tools

* JDK 17 (`jdk17`)
* Maven (`maven3`)
* Sonar Scanner

## Plugins

* Git
* Pipeline
* Docker
* SonarQube Scanner
* AWS Credentials
* Kubernetes CLI

## Credentials

* `github-creds`
* `docker_creds`
* `aws_creds`
* Sonar token

### Enable Docker usage

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

---

# 🏗️ 5. Infrastructure Pipeline (Terraform)

## Parameters

* `TF_WORKSPACE=dev`
* `DESTROY_INFRA=false`

## Flow

* Init → Workspace → Validate → Plan → Apply
* OR Destroy when enabled

### Backend (Recommended)

```hcl
terraform {
  backend "s3" {
    bucket         = "<bucket>"
    key            = "eks/terraform.tfstate"
    region         = "eu-west-3"
    use_lockfile = true
    encrypt        = true
  }
}
```

---

# 🌐 6. Connect to EKS

```bash
aws eks update-kubeconfig --region eu-west-3 --name <cluster>
kubectl get nodes
```

---

# ☸️ 7. Kubernetes Core Setup

## Ingress

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
```

## ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Get password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

## Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

# 🔄 8. Application CI Pipeline

## Parameter

* `IMAGE_TAG`

## Flow

* Compile → Scan → Analyze → Build → Push → GitOps

### Commands

```bash
mvn clean compile
trivy fs .
docker build -t hamoud07/bankapp:<tag> .
trivy image hamoud07/bankapp:<tag>
docker push hamoud07/bankapp:<tag>
```

### GitOps

* Update manifest
* Commit
* Push
* Deploy via ArgoCD

---

# 🚀 9. ArgoCD Deployment

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

* Connect repo
* Path: `k8s-manifests`
* Auto sync

---

# 📊 10. Monitoring

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

---

# 📊 Observability Best Practices

* Enable alerts in Prometheus
* Monitor pod restarts
* Use dashboards for SLIs
* Collect logs (ELK / Loki)

---

# 🔐 11. Security Best Practices

* IAM roles over static credentials
* Secrets in secure storage
* Image scanning before deploy
* Restricted security groups

---

# ⚡ 12. Automation Highlights

* Fully automated pipelines
* GitOps deployment
* No manual steps
* Multi-env support

---

# 💰 13. Cost Optimization

* Use t3.micro
* Destroy unused infra
* Monitor AWS costs

---

# 🧹 14. Cleanup

```bash
terraform destroy
```

---

# ✅ Validation

After setup, verify:

* Jenkins pipeline succeeds
* Docker image pushed
* ArgoCD status = Healthy
* App accessible
* Grafana dashboards working

---

# 🏁 Conclusion

This setup delivers a complete **enterprise DevSecOps platform** with:

* CI/CD automation
* GitOps deployment
* Secure pipelines
* Kubernetes infrastructure
* Observability

---
