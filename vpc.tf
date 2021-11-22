#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-dev-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "dev" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.dev.id
  map_public_ip_on_launch =  true

  tags = map(
    "Name", "terraform-eks-dev-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "terraform-eks-dev"
  }
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }
}

resource "aws_route_table_association" "dev" {
  count = 2

  subnet_id      = aws_subnet.dev.*.id[count.index]
  route_table_id = aws_route_table.dev.id
}
