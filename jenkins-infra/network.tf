resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = merge(local.common_tags, { Name = "main", Company = "BriniSolutions" })
}

////subnet - public
resource "aws_subnet" "main-public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"
  tags                    = merge(local.common_tags, { Name = "main-public", Company = "BriniSolutions" })
}

////subnet - private
resource "aws_subnet" "main-private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  tags              = merge(local.common_tags, { Name = "main-private", Company = "BriniSolutions" })
}

///igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "igw", Company = "BriniSolutions" })
}

////route table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "rtb", Company = "BriniSolutions" })
}

///subnet association
resource "aws_route_table_association" "rtb-public" {
  subnet_id      = aws_subnet.main-public.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rtb-private" {
  subnet_id      = aws_subnet.main-private.id
  route_table_id = aws_route_table.rtb.id
}

