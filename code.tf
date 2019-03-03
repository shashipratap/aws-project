provider "aws" {
  access_key = "A"
  secret_key = ""
  region     = "us-east-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Route"
  }
}

resource "aws_eip" "nat" {

  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_sub1.id}"

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = "${aws_vpc.my_vpc.default_route_table_id}"

  route {
     
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  
  }

  tags = {
    Name = "default table"
  }
}


resource "aws_subnet" "public_sub1" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "public_sub1"
  }
}

resource "aws_subnet" "public_sub2" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "public_sub2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public_sub1.id}"
  route_table_id = "${aws_route_table.r.id}"
}
	
resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.public_sub2.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_subnet" "private_sub1" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "private_sub1"
  }
}

resource "aws_subnet" "private_sub2" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "private_sub2"
  }
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow public access"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]# add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]# add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]# add a CIDR block here
  }
}	


resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow public access"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    security_groups = ["${aws_security_group.public_sg.id}"]# add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    security_groups = ["${aws_security_group.public_sg.id}"]# add a CIDR block here
  }

ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    security_groups = ["${aws_security_group.public_sg.id}"]# add a CIDR block here
  }
}
	
resource "aws_instance" "Apache1" {
ami = "ami-04328208f4f0cf1fe"

subnet_id   = "${aws_subnet.public_sub1.id}"
instance_type = "t2.micro"
security_groups = ["${aws_security_group.public_sg.id}"]
key_name = "SP"
tags = {
Name = "Apache1"
}
}

resource "aws_instance" "Apache2" {
ami = "ami-04328208f4f0cf1fe"
instance_type = "t2.micro"

subnet_id   = "${aws_subnet.public_sub2.id}"
security_groups = ["${aws_security_group.public_sg.id}"]
key_name = "SP"
tags = {
Name = "Apache2"
}
}

resource "aws_instance" "Appserver1" {
ami = "ami-04328208f4f0cf1fe"
instance_type = "t2.micro"

subnet_id   = "${aws_subnet.private_sub1.id}"
security_groups = ["${aws_security_group.private_sg.id}"]
key_name = "SP"
tags = {
Name = "Appserver2" 
}
}

resource "aws_instance" "Appserver2" {
ami = "ami-04328208f4f0cf1fe"
instance_type = "t2.micro"

subnet_id   = "${aws_subnet.private_sub2.id}"
security_groups = ["${aws_security_group.private_sg.id}"]
key_name = "SP"
tags = {
Name = "Appserver2" 
}
}


resource "aws_route53_zone" "primary" {
  name = "rewarinews.ml"
}


resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "rewarinews.ml"
  type    = "A"

  alias {
    name                   = "${aws_lb.mylb.dns_name}"
    zone_id                = "${aws_lb.mylb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_lb" "mylb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.public_sg.id}"]
  subnets            = ["${aws_subnet.public_sub1.id}","${aws_subnet.public_sub2.id}"]

   tags = {
    Environment = "production"
  }
}

resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_lb.mylb.arn}"  
  port              = "80"  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.TG.arn}"
    type             = "forward"  
  }
}


resource "aws_lb_target_group" "TG" {
  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.my_vpc.id}"
health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/index.html"    
    port                = "80"  
  }
}


resource "aws_lb_target_group_attachment" "TG1" {
  target_group_arn = "${aws_lb_target_group.TG.arn}"
  target_id        = "${aws_instance.Apache1.id}"
  port             = 80
}



resource "aws_lb_target_group_attachment" "TG2" {
  target_group_arn = "${aws_lb_target_group.TG.arn}"
  target_id        = "${aws_instance.Apache2.id}"
  port             = 80
}
