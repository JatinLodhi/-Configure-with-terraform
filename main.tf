# Provider information.

provider "aws" {
  region  = "us-east-1"
  profile = "KS-profile"
}

# Create a key-pair

resource "aws_key_pair" "web-key" {
  key_name   = "web-key"
  public_key = file ("${path.module}/key.pub")
}


# Create an instance.

resource "aws_instance" "web" {
  ami           = "ami-026b57f3c383c2eec"
  instance_type = "t2.micro"
  security_groups = [ "allow_ssh_http" ]
  key_name     = "web-key"
  
  tags = {
    Name = "Web-Page"
  }
}

# Create a aws_security_group

resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = "vpc-03abe991acd5b7c81"


  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }



  tags = {
    Name = "allow_ssh_http"
  }

}



resource "null_resource" "nullremote15" {
# Stablished a connection.

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("${path.module}/key")
    host     = aws_instance.web.public_ip
  }
  
# To run a command on remote.
provisioner "remote-exec" {
     inline = [
      "sudo yum  install httpd  -y",
      "sudo  yum  install php  -y",
      "sudo systemctl start httpd",
      "sudo systemctl start httpd",
      "sudo yum install git -y",
      "sudo git clone https://github.com/JatinLodhi/jenkins.git   /var/www/html/tf"
      
    ]   
  }

}
resource "null_resource"  "nullremote14" {



provisioner "local-exec" {
   command = "start chrome http://3.87.143.67/tf/index.html"
  }

}




