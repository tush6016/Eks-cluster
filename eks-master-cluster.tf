provider "aws" {
  region     = "us-east-1"

}

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Production"
  }

}
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "prod-sub-1"
  }

}


resource "aws_instance" "eks-master" {
  ami               = "ami-026b57f3c383c2eec"
  instance_type     = "t3.small"
  availability_zone = "us-east-1a"
  key_name          = "verginiats"

  user_data = <<-EOF
                #!/bin/bash
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
                sudo yum -y install terraform
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
                chmod +x ./aws-iam-authenticator
                echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
                sudo mv -v /tmp/eksctl /usr/local/bin
                eksctl version
                sudo yum install git -y
                cd 
                git clone https://github.com/tush6016/learn-terraform-provision-eks-cluster.git
                cd learn-terraform-provision-eks-cluster/
                terraform init
                terraform apply
                yes
                EOF

  tags = {
    Name = "eks-master"
  }

}
