vpc = {
  name = "vpc"
  cidr = "10.160.0.0/16"

  public_subnet_a = "10.160.1.0/24"
  public_subnet_b = "10.160.2.0/24"
  public_subnet_c = "10.160.3.0/24"

  private_subnet_a = "10.160.131.0/24"
  private_subnet_b = "10.160.132.0/24"
  private_subnet_c = "10.160.133.0/24"

  database_subnet_a = "10.160.201.0/24"
  database_subnet_b = "10.160.202.0/24"
  database_subnet_c = "10.160.203.0/24"
}

enable_nat_gateway           = true
single_nat_gateway           = true
create_database_subnet_group = true