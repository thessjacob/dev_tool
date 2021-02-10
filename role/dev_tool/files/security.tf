resource "aws_key_pair" "dev_key" {
    key_name   = var.my_key_name
    public_key = var.my_key_value
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "allow ssh in"
    vpc_id      = aws_vpc.main.id

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
    name        = "allow_ssh_private"
    description = "allow ssh into private subnet"
    vpc_id      = aws_vpc.main.id

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

