packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ami_name_prefix" {
  type    = string
  default = "trushot-app"
}

source "amazon-ebs" "app" {
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region

  # Use latest Amazon Linux 2023
  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name        = "${var.ami_name_prefix}-{{timestamp}}"
    Environment = "base"
    ManagedBy   = "Packer"
    Built       = "{{timestamp}}"
  }
}

build {
  name = "trushot-app-ami"
  sources = [
    "source.amazon-ebs.app"
  ]

  # Update system packages
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      # Swap curl-minimal with full curl package to avoid conflicts
      "sudo yum swap -y curl-minimal curl",
      "sudo yum install -y jq wget git"
    ]
  }

  # Install Node.js 20.x LTS
  provisioner "shell" {
    inline = [
      "curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -",
      "sudo yum install -y nodejs",
      "node --version",
      "npm --version"
    ]
  }

  # Install PM2 globally for process management
  provisioner "shell" {
    inline = [
      "sudo npm install -g pm2",
      "pm2 --version"
    ]
  }

  # Install CloudWatch Agent
  provisioner "shell" {
    inline = [
      "wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm",
      "sudo rpm -U ./amazon-cloudwatch-agent.rpm",
      "rm -f ./amazon-cloudwatch-agent.rpm"
    ]
  }

  # Install AWS CLI v2
  provisioner "shell" {
    inline = [
      "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "rm -rf aws awscliv2.zip",
      "aws --version"
    ]
  }


  # Create application directory structure
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/app",
      "sudo mkdir -p /opt/app/logs",
      "sudo chown -R ec2-user:ec2-user /opt/app"
    ]
  }

  # Create PM2 ecosystem file placeholder
  provisioner "shell" {
    inline = [
      "cat <<'EOF' | sudo tee /opt/app/ecosystem.config.js",
      "module.exports = {",
      "  apps: [{",
      "    name: 'trushot-app',",
      "    script: 'npm',",
      "    args: 'start',",
      "    cwd: '/opt/app',",
      "    instances: 'max',",
      "    exec_mode: 'cluster',",
      "    env: {",
      "      NODE_ENV: 'production',",
      "      PORT: 3000",
      "    }",
      "  }]",
      "};",
      "EOF"
    ]
  }

  # Security hardening
  provisioner "shell" {
    inline = [
      # Disable root login
      "sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config",

      # Enable automatic security updates
      "sudo yum install -y dnf-automatic",
      "sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf",
      "sudo systemctl enable dnf-automatic.timer",

      # Set timezone
      "sudo timedatectl set-timezone UTC"
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo yum clean all",
      "sudo rm -rf /var/cache/yum",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "history -c"
    ]
  }
}
