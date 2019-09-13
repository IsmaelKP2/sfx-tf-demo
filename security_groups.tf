resource "aws_security_group" "allow_egress" {
  name        = "allow_egress"
  description = "Allow Egress traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow MySQL inbound traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self = true
    security_groups = ["${aws_security_group.allow_http.id}"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_sfx_mon" {
  name        = "allow_sfx_mon"
  description = "Allow SFX monitoring traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self = true
    # security_groups = ["${aws_security_group.allow_http.id}"]
  }
}