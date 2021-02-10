resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = var.my_user
        Environment = var.environment
    }
}

resource "aws_network_acl" "main" {
    vpc_id = aws_vpc.main.id

    ingress {
        protocol    = "tcp"
        rule_no     = 100
        action      = "allow"
        cidr_block  = var.my_ip
        from_port   = "22"
        to_port     = "22"
    }

    ingress {
        protocol    = -1
        rule_no     = 200
        action      = "allow"
        cidr_block  = var.vpc_cidr
        from_port   = 0
        to_port     = 0
    }

    egress {
         protocol    = -1
        rule_no     = 100
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 0
        to_port     = 0
    }
}

resource "aws_subnet" "private" {
    vpc_id      = aws_vpc.main.id
    cidr_block  = var.internal_subnet

    tags = {
        Name = "Private"
        User = var.my_user
    }
}

resource "aws_subnet" "public" {
    vpc_id      = aws_vpc.main.id
    cidr_block  = var.external_subnet

    tags = {
        Name = "Public"
        User = var.my_user
    }
}

resource "aws_internet_gateway" "igw_main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw_main"
    }
}

resource "aws_route_table" "out_route" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_main.id
    }

    tags = {
        Name = "out_route"
    }
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.out_route.id
}

resource "aws_eip" "eip_natgw" {
    vpc = true
    depends_on = [aws_internet_gateway.igw_main]
}

resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.eip_natgw.id
    subnet_id     = aws_subnet.public.id

    tags = {
        Name = "private_subnet_natgw"
    }
}

resource "aws_route_table" "nat_out" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id
    }

    route {
        cidr_block = var.my_ip
        gateway_id = aws_internet_gateway.igw_main.id
    }

    tags = {
        Name = "out_route_private"
    }
}

resource "aws_route_table_association" "b" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.nat_out.id
}

resource "aws_eip" "public_instance" {
    vpc = true

    instance = aws_instance.public_node.id
    associate_with_private_ip = "10.0.0.4"
    depends_on  = [aws_internet_gateway.igw_main]
}

resource "aws_network_interface" "instance1" {
    subnet_id = aws_subnet.public.id
    private_ips = ["10.0.0.4"]
    security_groups = [aws_security_group.allow_ssh.id]
}

resource "aws_eip" "private_instance" {
    vpc = true

    instance = aws_instance.private_node.id
    associate_with_private_ip = "10.0.1.4"
    depends_on  = [aws_internet_gateway.igw_main]
}

resource "aws_network_interface" "instance2" {
    subnet_id = aws_subnet.private.id
    private_ips = ["10.0.1.4"]
    security_groups = [aws_security_group.allow_ssh_private.id]
}