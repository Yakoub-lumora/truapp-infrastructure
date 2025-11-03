# TruShot Cloud Infrastructure

Production-grade AWS infrastructure for a Trushot application with distributed job processing, observability, and automated deployments.

**Portfolio by:** [Abdelillah Ait Yakoub](https://www.linkedin.com/in/abdelillah-ait-yakoub)

## What's In Here

**Docker** — Development environments for the app, worker, and monitoring stack
**Infrastructure** — Terraform modules for AWS (EC2, ECS, RDS, observability) and Packer AMI builder
**CI/CD** — GitHub Actions: auto-deploys to EC2 via CodeDeploy, builds and deploys ECS worker to ECR with health checks & rollback

## Quick Architecture

```
┌─────────────────────────────────────────────┐
│         User Traffic via CloudFront         │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
    ┌───▼────┐          ┌───▼────┐
    │   ALB  │          │ Grafana│
    │(routing)          │ (3000) │
    └───┬────┘          └────────┘
        │
    ┌───▼────────────────────────────┐
    │  EC2 Cluster (Auto Scaling)    │
    │  └─ App ( on port 3000)        │
    └───┬────────────────────────────┘
        │
    ┌───┴──────┬──────────────────────┐
    │          │                      │
  ┌─▼──┐  ┌───▼──┐            ┌──────▼────┐
  │ RDS│  │Redis │            │     S3    │
  │(DB)│  │Queue │            │ (Storage) │
  └────┘  └──────┘            └───────────┘

    ┌──────────────────────────────────────┐
    │  ECS Fargate (Worker Tasks)          │
    │  └─ Worker (Redis Queue processor)   │
    └──────────────────────────────────────┘

Monitoring: Prometheus scrapes metrics, Grafana visualizes them
```

## Key Features

- **Modular Terraform** — Separate modules for networking, compute, database, security, observability
- **Docker First** — Workers and observability modules runs in containers (dev and prod)
- **Custom AMI** — Packer builds optimized EC2 images (Docker, Node.js pre-installed)
- **Auto Scaling** — EC2 instances spin up/down based on load
- **Observability** — Prometheus + Grafana for metrics, Loki for logs (optional)
- **Database** — RDS PostgreSQL with read replicas
- **Storage** — S3 for images with signed URLs
- **Job Queue** — Redis for async processing

## Deploy It

### Prerequisites
- AWS Account with appropriate credentials
- Terraform installed
- Packer installed (for AMI building)

### Build Custom AMI
```bash
cd infrastructure/packer
packer validate app-ami.pkr.hcl
packer build app-ami.pkr.hcl
# Copy the AMI ID from output
```

### Deploy Infrastructure
```bash
cd infrastructure/terraform/environments/dev
# Update terraform.tfvars with your AMI ID and other variables
terraform init
terraform plan
terraform apply
```

### Deploy App
```bash
# SSH to EC2 instance
ssh ec2-user@<instance-ip>

# Pull latest code and start services
git pull origin main
docker-compose -f docker/dev/docker-compose.yml up -d
```

## Local Development

Run the full stack locally:
```bash
docker-compose -f docker/dev/docker-compose.yml up
```

Access:
- App: http://localhost:3000
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001

## Infrastructure Modules

| Module | Purpose |
|--------|---------|
| `networking` | VPC, subnets, security groups, ALB |
| `compute/ec2` | EC2 instances, auto-scaling groups |
| `compute/ecs` | ECS Fargate for containerized workloads |
| `compute/observability` | Prometheus + Grafana on ECS |
| `database` | RDS PostgreSQL setup |
| `security` | IAM roles and policies |
| `monitoring` | CloudWatch alarms and dashboards |

## Secrets Management

Sensitive data is managed via **AWS Secrets Manager** (production) and environment variables (local dev):
- Database credentials → Secrets Manager + RDS IAM auth
- API keys (Stripe, etc.) → Secrets Manager → ECS task environment
- Redis connection strings → Secrets Manager
- AWS access keys → IAM roles (no hardcoded keys)

Local development uses `.env` files (never committed). Production uses GitHub secrets → CodeDeploy/ECS environment variables.

## Monitoring & Troubleshooting

**Check app health:**
```bash
curl http://localhost:3000/api/health
```

**Check worker health:**
```bash
npm run worker:health
```

**View logs:**
```bash
tail -f logs/worker/$(date +%Y-%m-%d).log
```

**Prometheus queries:**
Go to http://localhost:9090 and query metrics like `up{job="app"}` or `http_active_requests`

## CI/CD Pipeline

**EC2 Deployment** (`ec2-deploy.yml`)
- Trigger: Push to `dev` (auto-deploy) or `main` (requires approval)
- Steps: Type check → Lint → Build Next.js → Package → Upload to S3 → CodeDeploy
- Features: Zero-downtime deployment, automatic rollback, health checks

**ECS Worker Deployment** (`ecs-worker-deploy.yml`)
- Trigger: Push to `dev` (auto-deploy) or `main-worker` (requires approval)
- Steps: Build Docker image → Push to ECR → Register new task definition → Update ECS service
- Features: Automatic rollback on failure, health verification, service stability wait
