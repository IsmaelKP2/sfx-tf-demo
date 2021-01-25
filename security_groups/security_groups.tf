resource "aws_security_group" "allow_egress" {
  name        = "allow_egress"
  description = "Allow Egress traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self = true
  }
  ingress {
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    self = true
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow MySQL inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self = true
    security_groups = [aws_security_group.allow_web.id]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic between members"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "allow_collectors" {
  name        = "allow_collectors"
  description = "Allow collector traffic between members"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9943
    to_port     = 9943
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr_block
    ]
  }
  ingress {
    from_port   = 13133
    to_port     = 13133
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr_block
    ]
  }
  egress {
    from_port   = 9943
    to_port     = 9943
    protocol    = "tcp"
    self = true
  }
  egress {
    from_port   = 13133
    to_port     = 13133
    protocol    = "tcp"
    self = true
  }
}