resource "aws_instance" "backend" {
  ami                         = "ami-08ca1d1e465fbfe0c"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-03ce2bf3f3b924a6c"
  vpc_security_group_ids      = [aws_security_group.backend.id]
  associate_public_ip_address = true
  key_name                    = "ec2-dev-key"
  iam_instance_profile        = aws_iam_instance_profile.backend.name

  tags = {
    Name = "ZendCraftBackEnd"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    iops        = 3000
    throughput  = 125
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "backend" {
  name        = "EC2SSMReadOnly"
  description = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "backend" {
  name = "EC2SSMReadOnly"
  role = aws_iam_role.backend.name
}

resource "aws_iam_role_policy_attachment" "backend_ssm_core" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "backend" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created 2025-07-26T00:25:20.125Z"
  vpc_id      = "vpc-01b893caede99cf38"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_anywhere" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_home" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "184.57.177.67/32"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
