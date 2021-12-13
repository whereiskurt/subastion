resource "aws_security_group" "subastion_public" {
  name = "subastion_public"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.golden.id
  ingress = [
    {
      description      = "HTTPS port to VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self=true
      prefix_list_ids=[]
      security_groups=[]
    },
    {
      description      = "SSH port to VPC "
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self=true
      prefix_list_ids=[]
      security_groups=[]
    },
    {
      description      = "OpenVPN port to VPC "
      from_port        = var.openvpn_port
      to_port          = var.openvpn_port
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self=true
      prefix_list_ids=[]
      security_groups=[]
    }        
  ]
  egress = [
    {
      description      = "All outbound from VPC"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self=true
      prefix_list_ids=[]
      security_groups=[]
    }
  ]
  tags = merge(var.aws_build_tags, {Name = "${var.name}_subastion_public"})
}