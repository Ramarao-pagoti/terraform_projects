locals {

  common_tags = {
    Project     = "phoenix-banking"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  public_subnets = {
    public-a = {
      az   = var.availability_zones[0]
    }
      public-b = {
          az   = var.availability_zones[1]
      }
  }

  private_app_subnets = {
    app-a = {
      az   = var.availability_zones[0]
    }
    app-b = {
      az   = var.availability_zones[1]
    }
  }

  private_db_subnets = {
    db-a = {
      az   = var.availability_zones[0]
    }
    db-b = {
      az   = var.availability_zones[1]
    }
  }
}