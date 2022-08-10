
# Find Linux Server ec2
data "aws_ami" "amazon-linux" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# Create Linux Server
resource "aws_instance" "ec2-sql" {

  ami = data.aws_ami.amazon-linux.id
  subnet_id = aws_subnet.private-subnet.id
  associate_public_ip_address = true
  instance_type = "t2.micro"
  tags = {
    Name  = "ec2-sql"
  }
}
