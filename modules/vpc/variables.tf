variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "172.16.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment for the VPC."
  type        = string
  default     = "dev"
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs."
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "idv-main-vpc"
}

variable "deploy_natgw" {
  description = "Whether to deploy NAT Gateways in the private subnets."
  type        = bool
  default     = false
}

# Private Subnet CIDR Variables
variable "private_subnet_tier_newbits" {
  description = "Number of additional bits to add to the VPC CIDR prefix for the private subnet tier allocation. Controls how many top-level subnet groups are possible (2^private_subnet_tier_newbits)."
  type        = number
  default     = 4
}

variable "private_subnet_tier_netnum" {
  description = "The network number (index) of the subnet tier to use for private subnets from the first cidrsubnet division."
  type        = number
  default     = 0
}

variable "private_subnet_newbits" {
  description = "Number of additional bits to add within the private subnet tier for individual private subnets. Controls how many private subnets can be created (2^private_subnet_newbits)."
  type        = number
  default     = 2
}

# Public Subnet CIDR Variables
variable "public_subnet_tier_newbits" {
  description = "Number of additional bits to add to the VPC CIDR prefix for the public subnet tier allocation. Controls how many top-level subnet groups are possible (2^public_subnet_tier_newbits)."
  type        = number
  default     = 2
}

variable "public_subnet_tier_netnum" {
  description = "The network number (index) of the subnet tier to use for public subnets from the first cidrsubnet division."
  type        = number
  default     = 0
}

variable "public_subnet_newbits" {
  description = "Number of additional bits to add within the public subnet tier for individual public subnets. Controls how many public subnets can be created (2^public_subnet_newbits)."
  type        = number
  default     = 2
}


variable "vpc_endpoints" {
  description = "A map of VPC endpoints to create, where the key is an identifier for the endpoint and the value is the AWS service name (e.g., 'com.amazonaws.eu-west-2.ec2')."
  type        = map(string)
  default = {
    cloudwatch_logs_endpoint = "com.amazonaws.eu-west-2.logs",
    ec2_messages_endpoint    = "com.amazonaws.eu-west-2.ec2messages",
    ec2_endpoint             = "com.amazonaws.eu-west-2.ec2",
    ssm_endpoint             = "com.amazonaws.eu-west-2.ssm",
    ssm_messages_endpoint    = "com.amazonaws.eu-west-2.ssmmessages"
  }

}
