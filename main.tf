resource "aws_security_group" "global_sg" {
  name        = "serveraccess"
  description = "This is to allow server to outside"
  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "commonsg"
    env  = "dev"
  }
}

resource "aws_instance" "global-instance" {
  ami                  = "ami-087c17d1fe0178315"
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.global_sg.name}"]
  iam_instance_profile = aws_iam_instance_profile.global-instance-profile.id
  tags = {
    Name = "webinstance"
    env  = "dev"
  }
}

resource "aws_iam_role" "global-instance-role" {
  name = "web_instance_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "webrole"
    env  = "dev"
  }
}

resource "aws_iam_policy_attachment" "global-policy-attachment" {
  name       = "remote-access-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles      = ["${aws_iam_role.global-instance-role.id}"]
}

resource "aws_iam_instance_profile" "global-instance-profile" {
  name = "webprofile"
  role = aws_iam_role.global-instance-role.name
}