output "vpc_id" {
    value = aws_vpc.this.id 
}

output "private_app_subnet_ids" {
    value = values(aws_subnet.private_app)[*].id
}
output "public_subnet_ids" {
    value = values(aws_subnet.public)[*].id  
}
output "private_data_subnet_ids" {
    value = values(aws_subnet.private_data)[*].id
  
}