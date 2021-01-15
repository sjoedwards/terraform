// Pulls back the list of availability zones for the region we're using
data "aws_availability_zones" "available" {
  state = "available"
}

// Defines our virtual private cluster, says all the containers will have an IP starting with 172.17
resource "aws_vpc" "main" {
  cidr_block = "172.17.0.0/16"

  tags = {
    Name = "${var.ecs_service_name}-VPC"
  }
}


# Create var.az_count private subnets, each in a different AZ
# AZ is availability zone
# Count.index is like the loop for the availability zones being iterated.
# For each availability zone, define a subnet, and connect it to the VPC
resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "${var.ecs_service_name}-net-private-${count.index}"
  }
}

# Create var.az_count public subnets, each in a different AZ
# As above, but public subnets
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.ecs_service_name}-net-public-${count.index}"
  }
}

# Internet Gateway for the public subnet
# Public subnet connects to the internet gateway to recieve traffic
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.ecs_service_name}-IGW"
  }
}
