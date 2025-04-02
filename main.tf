####################################
#  Provider
####################################
provider "aws" {
  region = "us-east-1"
}

####################################
#  Security Group
####################################
resource "aws_security_group" "locust_sg" {
  name        = "locust-sg"
  description = "Allow inbound traffic for Locust Master/Workers and SSH"

  # SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Locust UI on 8089
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Locust Master <-> Worker comms (5557 & 5558)
  # "self = true" allows traffic between instances in this same security group
  ingress {
    from_port   = 5557
    to_port     = 5558
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################################
#  Locust Master Instance
####################################
resource "aws_instance" "locust_master" {
  ami           = "ami-0cdaca59d3d65d47c" # Amazon Linux 2 ARM in us-east-1
  instance_type = "t4g.micro"
  key_name      = "" # Replace with your key pair
  vpc_security_group_ids = [aws_security_group.locust_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -aG docker ec2-user

  # (Optional) If your Docker Hub repo is private, you’d need a docker login here
  docker login -u loginname -p dockerpat

  # Pull the image explicitly
  docker pull name/project:image

    # Pull & run Locust master container, publishing ports 8089, 5557, 5558
    docker run -d \
      -p 8089:8089 \
      -p 5557:5557 \
      -p 5558:5558 \
      name/project:image \
      -f locustfile.py --master --web-host 0.0.0.0 --master-port 5557
  EOF

  tags = {
    Name = "Locust-Master"
  }
}

####################################
#  Locust Worker Instances
####################################
resource "aws_instance" "locust_worker" {
  count         = 2
  ami           = "ami-0cdaca59d3d65d47c"
  instance_type = "t4g.micro"
  key_name      = ""
  vpc_security_group_ids = [aws_security_group.locust_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -aG docker ec2-user

    # Replace MASTER_PRIVATE_IP dynamically
    MASTER_IP="${aws_instance.locust_master.private_ip}"

  # (Optional) If your Docker Hub repo is private, you’d need a docker login here
     docker login -u loginname -p dockerpat

    # Pull the image explicitly
     docker pull name/project:image

    # Pull & run Locust worker container, pointing to the master's IP/port
    docker run -d \
      name/project:image \
      -f locustfile.py --worker --master-host $MASTER_IP --master-port 5557
  EOF

  tags = {
    Name = "Locust-Worker-${count.index}"
  }
}