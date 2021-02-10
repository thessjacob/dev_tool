provider "aws" {
    region = var.availability_zone_names
}

resource "aws_instance" "public_node" {
  ami           = var.image_id
  instance_type = var.instance_size
  key_name = var.my_key_name

  network_interface {
    network_interface_id = aws_network_interface.instance1.id
    device_index         = 0
  }

  tags = {
    Name = "public_node1"
  }
}

resource "aws_instance" "private_node" {
  ami           = var.image_id
  instance_type = var.instance_size
  key_name = var.my_key_name

  network_interface {
    network_interface_id = aws_network_interface.instance2.id
    device_index         = 0
  }

  tags = {
    Name = "private_node1"
  }
}