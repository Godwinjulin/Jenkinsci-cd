resource "aws_instance" "jenkins-server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.jenkins-server.key_name
  subnet_id              = aws_subnet.main-public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_jenkins.id]
  user_data_base64       = data.cloudinit_config.userdata.rendered

  lifecycle {
    ignore_changes = [ami, user_data_base64]
  }

  tags = merge(local.common_tags, { Name = "jenkins-server", Company = "BriniSolutions" })
}

///key
resource "aws_key_pair" "jenkins-server" {
  key_name   = "jenkins-server"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgpxE0FxpgOBZtUVwDXTkTmnPeKQ+U2L+cm+1jBmzLbp+C5wGYD6cVd6YAbunANRVRwqc6LEAnvh3TUbYfdDPpIUc/AaOfer42L8MPlx+H6nXGirx6s2KhgIwsK6gCgKdk36MARhP0DyPAJg5BclWYTGylcQmH4YxDbbNpevO3hTPXQX0/Wk+SUIpnlJ+oLn5NTerYMFdjgfrqPMzypJn1Y0Waz4ThHg1B6oddByrGAImyYqgDKkPwaH3S/DxcF+iWI7U1dtQywRKi0dhUzxXESuwo/1DE/YVNPLx7VcXlnWHHjfztjvOJCCVhPmr3F9v4RP0mui2k+pY8k5WbtePBP7Q65eFUEmMWOdshkFjYLvxYZLXjpirC1mtEiRuS/qEeEJLVfXP8BMs/6sPeKrB6INVZ0VgpDdn7N7wtt0nnwhtEzRG1kUn0X0C8K6lfR0AtFFEWu7RkDSFz7YgoOl+8ekUFvxijr1buVSZuFm2NunGq1X59HsT7I0If0LweoG8= nicholasaidudo@Nicholass-MacBook-Air.local"
}

///jenkins sg
resource "aws_security_group" "allow_ssh_jenkins" {
  name        = join("-", [local.network.Environment, "allow_ssh_jenkins"])
  description = "Allow ssh and jenkins inbound traffic"
  vpc_id      = aws_vpc.main.id


  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "securitygrp-jenkins", Company = "BriniSolutions" })

}