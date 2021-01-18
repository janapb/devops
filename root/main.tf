 module "remotestate"{
  source               = "../remotestate"
  subscription_id     = var.subscription_id
  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  }

/*
module "dev"{
  #source              = "github.com/janapb/devops.git?ref=master"
  source               = "../Landinzone"
  subscription_id     = var.subscription_id
  client_id           = var.client_id
  client_secret       = var.client_secret
  tenant_id           = var.tenant_id
  #rg            = var.rg
  #peering     = var.peering
  #subnet       = var.subnet
  #vnet     = var.vnet
  }

  module "virtualmachine"{
  source               = "../virtualmachine"
  }


data "terraform_remote_state" "vpc" {
  backend = "remote"
}

output "remote"{
  value=data.terraform_remote_state.vpc
}
*/