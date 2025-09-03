#!/bin/bash
set -e

# NOTE: This user-data assumes a custom AMI with Node.js, PM2, CloudWatch Agent, SSM Agent pre-installed
# Build AMI using: infrastructure/packer/app-ami.pkr.hcl
# Application deployment is handled by CI/CD (GitHub Actions) via AWS Systems Manager (SSM)

# Ensure SSM Agent is running (Amazon Linux 2023 has it pre-installed)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Update CloudWatch Agent config with environment-specific values
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_iowait", "rename": "CPU_IOWAIT", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${project_name}-${environment}-system",
            "log_stream_name": "{instance_id}/messages"
          },
          {
            "file_path": "/opt/app/.next/logs/app.log",
            "log_group_name": "${project_name}-${environment}-app",
            "log_stream_name": "{instance_id}/app"
          },
          {
            "file_path": "/home/ec2-user/.pm2/logs/*.log",
            "log_group_name": "${project_name}-${environment}-pm2",
            "log_stream_name": "{instance_id}/pm2"
          }
        ]
      }
    }
  }
}
EOF

# Restart CloudWatch Agent with new config
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Fetch environment variables from SSM Parameter Store
mkdir -p /opt/app
cd /opt/app

# Create .env file from SSM
aws ssm get-parameters-by-path \
  --path "/${project_name}/${environment}/" \
  --with-decryption \
  --region ${region} \
  --query "Parameters[*].[Name,Value]" \
  --output text | while read name value; do
    param_name=$(echo $name | awk -F'/' '{print $NF}')
    echo "$param_name=$value" >> .env
done

# Set proper permissions
sudo chown -R ec2-user:ec2-user /opt/app

# Start PM2 at boot (application will be deployed by CI/CD)
sudo -u ec2-user pm2 startup systemd -u ec2-user --hp /home/ec2-user
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

# Signal that instance is ready
echo "User data completed - waiting for CI/CD deployment"
