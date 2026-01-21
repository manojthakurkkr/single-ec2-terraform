# 4. Output the Connection Details
output "instance_public_ip" {
  value       = aws_instance.my_ubuntu.public_ip
  description = "The public IP of the Ubuntu instance"
}

output "ssh_command" {
  value       = "ssh -i C:/Users/ManojKumar/.ssh/id_rsa  ubuntu@${aws_instance.my_ubuntu.public_ip}"
  description = "Command to connect to the instance"
}
