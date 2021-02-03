resource "aws_security_group" "allow_egress" {
  name        = "Allow Egress"
  description = "Allow Egress traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name        = "Web"
  description = "Web inbound traffic"
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
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mysql" {
  name        = "Mysql"
  description = "MySQL inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self = true
    security_groups = [aws_security_group.web.id]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "Allow SSH"
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
  name        = "Allow All"
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

resource "aws_security_group" "collectors" {
  name        = "Collectors"
  description = "Collector traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9411
    to_port     = 9411
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr_block
    ]
  }
  ingress {
    from_port   = 9943
    to_port     = 9943
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr_block
    ]
  }
  ingress {
    from_port   = 6060
    to_port     = 6060
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr_block
    ]
  }
  ingress {
    from_port   = 7276
    to_port     = 7276
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
    from_port   = 9411
    to_port     = 9411
    protocol    = "tcp"
    self = true
  }
  egress {
    from_port   = 9943
    to_port     = 9943
    protocol    = "tcp"
    self = true
  }
  egress {
    from_port   = 6060
    to_port     = 6060
    protocol    = "tcp"
    self = true
  }
  egress {
    from_port   = 7276
    to_port     = 7276
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