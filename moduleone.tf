#--------------------------

# PROVIDERS

provider "aws" {
    region = "eu-west-1"
}
#

#----------------------------
# RESOURCES

resource "aws_instance" "jenkins" {
    name = "len_nginx_1"
    ami = "${var.ami_len_jenk}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.len_subnet_1.id}"
    vpc_security_group_ids = ["${aws_security_group.len_sg.id}"]
    key_name = "len_terra"
}

resource "aws_instance" "len_nginx"{
    name = "len_nginx_2"
    ami = "ami-035966e8adab4aaad"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.len_subnet_2.id}"
    vpc_security_group_ids = ["${aws_security_group.len_sg.id}"]
    key_name = "len_terra"
}

resource "aws_key_pair" "deployer"{
    key_name = "len_terra"
    public_key = "${var.dontlook}"
}






#-------------------------------
# NETWORKING

resource "aws_vpc" "len_vpc"{
    cidr_block = "${var.network_address_space}"
    enable_dns_hostnames = "true"
}

resource "aws_internet_gateway" "len_igw"{
    vpc_id = "${aws_vpc.len_vpc.id}"
}

resource "aws_subnet" "len_subnet_1"{
    cidr_block = "${var.subnet_1}"
    vpc_id = "${aws_vpc.len_vpc.id}"
    map_public_ip_on_launch = "true"
}

resource "aws_subnet" "len_subnet_2"{
    cidr_block = "${var.subnet_2}"
    vpc_id = "${aws_vpc.len_vpc.id}"
    map_public_ip_on_launch = "true"
}

# Routing 

resource "aws_route_table" "rtb"{
    vpc_id = "${aws_vpc.len_vpc.id}"

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id ="${aws_internet_gateway.len_igw.id}"
    }
}

resource "aws_route_table_association" "rta_subnet1"{
    subnet_id = "${aws_subnet.len_subnet_1.id}"
    route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta_subnet2"{
    subnet_id = "${aws_subnet.len_subnet_2.id}"
    route_table_id = "${aws_route_table.rtb.id}"

}

# Security Groups

resource "aws_security_group" "len_sg"{
    name = "len_sg"
    vpc_id = "${aws_vpc.len_vpc.id}"


# SSH

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# HTTP

    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# HTTPS

    ingress{
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# Custom TCP Rule

    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# Egress 

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

