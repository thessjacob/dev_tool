resource "aws_key_pair" "dev_key" {
    key_name   = var.my_key_name
    public_key = var.my_key_value
}

resource "aws_security_group" "allow_ssh" {
    vpc_id      = aws_vpc.main.id
    name        = "allow_ssh"
    description = "allow ssh into public subnet"   
    
    ingress {
        description = "nginx from my ip"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [var.my_ip, var.vpc_cidr]
    }
      
    ingress {
        description = "ssh from my ip"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip, var.vpc_cidr]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_ssh_private" {
    vpc_id      = aws_vpc.main.id
    name        = "allow_ssh_private"
    description = "allow ssh into private subnet"
    
    ingress {
        description = "mysql from my ip/internally"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = [var.my_ip, var.vpc_cidr]
    }
        
    ingress {
        description = "ssh from my ip/internally"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip, var.vpc_cidr]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

