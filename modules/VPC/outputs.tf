output "vpc_id" {
    value = aws_vpc.this.id 
}

output "public_subnet_id" {
    value = aws_subnet.public.id 
}

output "private_subnet_app_id" {
    value = aws_subnet.private_app.id
}

output "private_subnet_data_id" {
    value = aws_subnet.private_data
}