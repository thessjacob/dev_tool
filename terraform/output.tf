output "instance1_ip" {
    value = aws_eip.public_instance.public_ip
}

output "instance2_ip" {
    value = aws_eip.private_instance.public_ip
}