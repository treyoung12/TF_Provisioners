terraform {
  cloud {
    organization = "Terraform-tester"

    workspaces {
      name = "Provisioners"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.39.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#data sources allow us to externally reference resources
data "aws_vpc" "main" {
  id = "vpc-0cd6327e934866cdf"
}

#security group that allows open internet and ssh from my computer only
resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My server Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [{
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [] #not needed because not using ipv6
    prefix_list_ids = []
    security_groups = []
    self = false
  }, 
  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["108.248.217.30/32"]
    ipv6_cidr_blocks = [] #not needed because not using ipv6
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress {
    description = "Outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }

}

#resource blocks (my server block and aws key pair block)/ deploys a server with user data script using cloud-init to pre-configure the VM
resource "aws_instance" "my_server" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]

  # user data script
  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "MyServer"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBPgFrDlXZS55SuqrXU9KtaYd/9lCIKovlLTpmHEn/8z69LbOg3mXTY2RKYfexgqO7AxsBx1h9hpc7DjN49QfnXmruSf/hPQgiahExIJEIl3ilJZqTt4hi6PoY0YNdwF1aLGQui0MJI7p3J6J/UeB32VYQnH0tBeFU3JcZkmVeXYiP/CDkLikV5z4v6qlkhGjk+YSJiTOkiPbXf+0UULMpTowpMqngDGfoMDzduLoddCy9WJjxfpr3b0ed6LWjKW9nqr8/HnZEOUkVbgpQut1tECdF21Sxzamq3iShcTUFohSWhR1KLmxHWy7IyWeA0M2nP2cskLwSXZ1u3ou9Sjjkz9PF/N7Hf15R1JZmFkYruM/jKBU/98YkpL9UjutCmzS4o+64PD4w/d3NH2UQVnzKUZVzUIxqdEWnBvPQT72E57Jlv0Tz2VnVBwFxNF9kwOZJVsAyH9Smp8+VX1MbKQpveOIlxLQHW1uMSs/Yxbs/qhc4whxsgzc4pMvB8ki91cs= ohhmy097@DESKTOP-84F9R34"
}

data "template_file" "user_data"{
  template = file("./userdata.yaml")
}

#outputs public ip address of the spun up server
output "public_ip"{
  value = aws_instance.my_server.public_ip
}

# use command <ssh ec2-user@$(terraform output -raw public ip) -i /home/ohhmy097/.ssh/terraform> to ssh into the device