# Default Security Group
resource "aws_default_security_group" "default_sec_group" {
  vpc_id = var.main_vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [var.my_public_ip]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "Default Security Group"
  }
}

# Creating a key-pair resource
resource "aws_key_pair" "test_ssh_key" {
  key_name   = "testing_ssh_key"
  public_key = file("/home/cking/.ssh/cteam_rsa.pub")


}

# Creating a data source to fetch the latest Amazon Linux 2 Image in your region
data "aws_ami" "latest_amazon_linux2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Spinning up an EC2 Instance
resource "aws_instance" "my_vm" {
  ami           = data.aws_ami.latest_amazon_linux2.id
  instance_type = "t2.micro"
  user_data     = file("./entry-script.sh") # running the script on the EC2 instance at boot

  subnet_id                   = var.web_subnet_id 
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = true
  key_name                    = "testing_ssh_key"

  tags = {
    "Name" = "My EC2 Intance - Amazon Linux 2"
  }
}

# Connect to the server by running: ssh -i ./test_rsa ec2-user@EC2_PUBLIC_IP
# You may find the EC2 public ip on the EC2 Dashboard

# Connect with the Browser to the EC2 public ip address and ports 80 and 8080