# VPC Module

This module creates an AWS VPC with public and private subnets spread across all available availability zones in the target region. It includes optional VPC flow logs (sent to CloudWatch) and optional NAT gateways for outbound internet access from private subnets.

## Resources Created

- **VPC** — The core VPC with configurable CIDR block and DNS settings.
- **Public Subnets** — One public subnet per availability zone, with dedicated route tables, route table associations, and routes to the internet gateway.
- **Internet Gateway** — Provides internet access for public subnets.
- **Private Subnets** — One private subnet per availability zone, with dedicated route tables and route table associations.
- **NAT Gateways** *(optional)* — One NAT gateway per AZ (placed in public subnets) with associated Elastic IPs, providing outbound internet access for private subnets.
- **VPC Flow Logs** *(optional)* — Captures all traffic flow logs and sends them to a CloudWatch Log Group. Includes the required IAM role and policy for the flow log service.
- **VPC Endpoints** — An S3 gateway endpoint associated with private route tables, and configurable interface endpoints for AWS services (e.g., EC2, SSM, CloudWatch Logs). Interface endpoints are placed in all private subnets with private DNS enabled.
- **Endpoint Security Group** — A security group for interface VPC endpoints allowing HTTPS (443) ingress from private subnet CIDRs and egress to the internet.

## Subnet CIDR Allocation

Both public and private subnet CIDRs are calculated automatically from the VPC CIDR using a two-level `cidrsubnet` scheme:

**Private subnets:**

```terraform
cidrsubnet(cidrsubnet(vpc_cidr, private_subnet_tier_newbits, private_subnet_tier_netnum), private_subnet_newbits, index)
```

**Public subnets:**

```terraform
cidrsubnet(cidrsubnet(vpc_cidr, public_subnet_tier_newbits, public_subnet_tier_netnum), public_subnet_newbits, index)
```

1. **Inner call** — Divides the VPC CIDR into `2^*_tier_newbits` top-level groups and selects group `*_tier_netnum`.
2. **Outer call** — Divides that group into `2^*_subnet_newbits` individual subnets, one per availability zone.

### Example (defaults with a /16 VPC)

**Private subnets:**

| Level | newbits | netnum | Resulting prefix | Possible blocks |
| --- | --- | --- | --- | --- |
| VPC | — | — | `/16` | — |
| Tier (inner) | 4 | 0 | `/20` | 16 groups |
| Private subnet (outer) | 2 | 0-3 | `/22` | 4 subnets per group |

**Public subnets:**

| Level | newbits | netnum | Resulting prefix | Possible blocks |
| --- | --- | --- | --- | --- |
| VPC | — | — | `/16` | — |
| Tier (inner) | 2 | 0 | `/18` | 4 groups |
| Public subnet (outer) | 2 | 0-3 | `/20` | 4 subnets per group |

## Variables

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `cidr_block` | `string` | `172.16.0.0/16` | The CIDR block for the VPC. |
| `enable_dns_hostnames` | `bool` | `true` | Whether to enable DNS hostnames in the VPC. |
| `enable_dns_support` | `bool` | `true` | Whether to enable DNS support in the VPC. |
| `environment` | `string` | `dev` | The environment for the VPC (e.g. `dev`, `staging`, `prod`). |
| `enable_flow_logs` | `bool` | `false` | Whether to enable VPC flow logs to CloudWatch. |
| `vpc_name` | `string` | `idv-main-vpc` | The name tag applied to the VPC and used as a prefix for related resource names. |
| `deploy_natgw` | `bool` | `false` | Whether to deploy NAT gateways in the public subnets for private subnet internet access. |
| `private_subnet_tier_newbits` | `number` | `4` | Number of additional bits added to the VPC CIDR prefix for the private subnet tier allocation. Controls how many top-level private subnet groups are possible (`2^private_subnet_tier_newbits`). |
| `private_subnet_tier_netnum` | `number` | `0` | The network number (index) of the subnet tier to use for private subnets. |
| `private_subnet_newbits` | `number` | `2` | Number of additional bits added within the private subnet tier for individual private subnets. Controls how many private subnets can be created (`2^private_subnet_newbits`). |
| `public_subnet_tier_newbits` | `number` | `2` | Number of additional bits added to the VPC CIDR prefix for the public subnet tier allocation. Controls how many top-level public subnet groups are possible (`2^public_subnet_tier_newbits`). |
| `public_subnet_tier_netnum` | `number` | `0` | The network number (index) of the subnet tier to use for public subnets. |
| `public_subnet_newbits` | `number` | `2` | Number of additional bits added within the public subnet tier for individual public subnets. Controls how many public subnets can be created (`2^public_subnet_newbits`). |
| `vpc_endpoints` | `map(string)` | See below* | A map of interface VPC endpoints to create, where the key is an identifier and the value is the AWS service name (e.g., `com.amazonaws.eu-west-2.ec2`). |

\*Default VPC endpoints (configured for `eu-west-2` - update for your region):

```hcl
{
  cloudwatch_logs_endpoint = "com.amazonaws.eu-west-2.logs"
  ec2_messages_endpoint    = "com.amazonaws.eu-west-2.ec2messages"
  ec2_endpoint             = "com.amazonaws.eu-west-2.ec2"
  ssm_endpoint             = "com.amazonaws.eu-west-2.ssm"
  ssm_messages_endpoint    = "com.amazonaws.eu-west-2.ssmmessages"
}
```

**Note:** The S3 gateway endpoint is automatically configured for the current region. Interface endpoint service names must match your deployment region.

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  cidr_block       = "10.0.0.0/16"
  vpc_name         = "my-vpc"
  environment      = "prod"
  enable_flow_logs = true
  deploy_natgw     = true

  # Private subnets: divide VPC into 16 groups (/20s), use group 0,
  # then split into 4 private subnets (/22s)
  private_subnet_tier_newbits = 4
  private_subnet_tier_netnum  = 0
  private_subnet_newbits      = 2

  # Public subnets: divide VPC into 4 groups (/18s), use group 0,
  # then split into 4 public subnets (/20s)
  public_subnet_tier_newbits = 2
  public_subnet_tier_netnum  = 0
  public_subnet_newbits      = 2

  # Optionally customize VPC endpoints (defaults shown above)
  vpc_endpoints = {
    ssm_endpoint = "com.amazonaws.us-east-1.ssm"
    ec2_endpoint = "com.amazonaws.us-east-1.ec2"
  }
}
```
