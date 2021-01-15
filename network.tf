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
# Bound to the ID of the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.ecs_service_name}-IGW"
  }
}

# Route the public subnet traffic through the IGW
# Send external (or internet) traffic to the internet gateway
# They will by default be associated with the main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
# EIP is an elastic IP
resource "aws_eip" "gw" {
  # Create 2, one for each AZ
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.ecs_service_name}-EIP"
  }
}

# NAT gateway allows traffic OUT but not internet traffic IN - used for private subnets
resource "aws_nat_gateway" "gw" {
  # Make 2, one for each availability zone
  count = var.az_count
  # Asterisk is replaced by the second argument, 1 or 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)

  tags = {
    Name = "${var.ecs_service_name}-NAT"
  }
}


# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
#A route table contains a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed.
resource "aws_route_table" "private" {
  # Make 2, one for each subnet
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    # Asterisk is replaced by the second argument, 1 or 2
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }

  tags = {
    Name = "${var.ecs_service_name}-rt-private-${count.index}"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count = var.az_count
  # Values 1 and 2 ensure that they are connecting to the subroute in the correct AZ
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
