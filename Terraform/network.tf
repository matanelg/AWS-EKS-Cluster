

#=====  VPC =====#
resource "aws_vpc" "main" {
  cidr_block                       = "10.10.0.0/16" # The CIDR block for the VPC.
  instance_tenancy                 = "default"      # Makes your instances shared on the host.
  enable_dns_support               = "true"         # Required for EKS. Enable/disable DNS support in the VPC.
  enable_dns_hostnames             = "true"         # Required for EKS. Enable/disable DNS hostnames in the VPC.
  enable_classiclink               = "false"        # Enable/disable ClassicLink for the VPC.
  enable_classiclink_dns_support   = false          # Enable/disable ClassicLink DNS Support for the VPC.
  assign_generated_ipv6_cidr_block = false          # Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC.
  tags = {
    Name = "main"
  }
}


#===== SUBNETS =====#
resource "aws_subnet" "public-01-1a" {
  vpc_id                  = aws_vpc.main.id # The VPC ID.
  cidr_block              = "10.10.0.0/24"  # The CIDR block for the subnet.
  availability_zone       = "us-east-1a"    # The AZ for the subnet.  
  map_public_ip_on_launch = true            # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  tags = {
    Name                        = "public-01-1a"
    "kubernetes.io/cluster/eks" = "shared"
  }
}

resource "aws_subnet" "public-02-1b" {
  vpc_id                  = aws_vpc.main.id # The VPC ID.
  cidr_block              = "10.10.2.0/24"  # The CIDR block for the subnet.
  availability_zone       = "us-east-1b"    # The AZ for the subnet.  
  map_public_ip_on_launch = true            # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  tags = {
    Name                        = "public-01-1b"
    "kubernetes.io/cluster/eks" = "shared"
  }
}

resource "aws_subnet" "private-01-1a" {
  vpc_id            = aws_vpc.main.id # The VPC ID.
  cidr_block        = "10.10.3.0/24"  # The CIDR block for the subnet.
  availability_zone = "us-east-1a"    # The AZ for the subnet.  
  tags = {
    Name                        = "private-01-1a"
    "kubernetes.io/cluster/eks" = "shared"
    "k8s.io/cluster-autoscaler/enabled" = true
    "k8s.io/cluster-autoscaler/eks" = "owned"
  }
}

resource "aws_subnet" "private-02-1b" {
  vpc_id            = aws_vpc.main.id # The VPC ID.
  cidr_block        = "10.10.4.0/24"  # The CIDR block for the subnet.
  availability_zone = "us-east-1b"    # The AZ for the subnet.  
  tags = {
    Name                        = "private-02-1b"
    "kubernetes.io/cluster/eks" = "shared"
    "k8s.io/cluster-autoscaler/enabled" = true
    "k8s.io/cluster-autoscaler/eks" = "owned"
  }
}


#===== INTERNET GATEWAY =====#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # The VPC ID to create in.
  tags = {
    Name = "igw"
  }
}


#===== EIP =====#
resource "aws_eip" "eip-01" {
  vpc        = true                       # If the EIP is in a VPC or not.
  depends_on = [aws_internet_gateway.igw] # EIP may require IGW to exist prior to association.
  tags = {
    Name = "eip-01"
  }
}


#===== NAT GATEWAY =====#
resource "aws_nat_gateway" "nat-01-1a" {
  allocation_id = aws_eip.eip-01.id          # The Allocation ID of the Elastic IP address for the gateway.
  subnet_id     = aws_subnet.public-01-1a.id # The Subnet ID of the subnet in which to place the gateway.
  depends_on    = [aws_internet_gateway.igw] # ig will created first and then the nat
  tags = {
    Name = "nat-01-1a"
  }
}


#===== ROUTE TABLE =====#
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id # The VPC ID.
  route {
    cidr_block = "0.0.0.0/0"                 # The CIDR block of the route.
    gateway_id = aws_internet_gateway.igw.id # Identifier of a VPC internet gateway or a virtual private gateway.
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table-01" {
  vpc_id = aws_vpc.main.id # The VPC ID.
  route {
    cidr_block     = "0.0.0.0/0"                  # The CIDR block of the route.    
    nat_gateway_id = aws_nat_gateway.nat-01-1a.id # Identifier of a VPC NAT gateway.
  }
  tags = {
    Name = "private-route-table-01"
  }
}


#===== ROUTE TABLE ASSOCIATION =====#
resource "aws_route_table_association" "assoc-public-01-1a" {
  subnet_id      = aws_subnet.public-01-1a.id            # The subnet ID to create an association.
  route_table_id = aws_route_table.public-route-table.id # The ID of the routing table to associate with.
}

resource "aws_route_table_association" "assoc-public-02-1b" {
  subnet_id      = aws_subnet.public-02-1b.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "assoc-private-01-1a" {
  subnet_id      = aws_subnet.private-01-1a.id
  route_table_id = aws_route_table.private-route-table-01.id
}

resource "aws_route_table_association" "assoc-private-02-1b" {
  subnet_id      = aws_subnet.private-02-1b.id
  route_table_id = aws_route_table.private-route-table-01.id
}





# Resource:
# aws_vpc - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
# aws_subnet - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# aws_internet_gateway - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# aws_eip - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# aws_nat_gateway - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
# aws_route_table - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# aws_route_table_association - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
