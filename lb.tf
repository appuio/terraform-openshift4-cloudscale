module "lb" {
  source = "git::https://github.com/appuio/terraform-modules.git//modules/vshn-lbaas-cloudscale?ref=feat/cloudscale-lb"

  node_name_suffix       = local.node_name_suffix
  cluster_id             = var.cluster_id
  region                 = var.region
  ssh_keys               = var.ssh_keys
  privnet_id             = local.privnet_uuid
  lb_count               = var.lb_count
  lb_flavor              = var.lb_flavor
  control_vshn_net_token = var.control_vshn_net_token
  team                   = var.team
  additional_networks    = var.additional_lb_networks

  router_backends          = module.infra.ip_addresses[*]
  bootstrap_node           = var.bootstrap_count > 0 ? cidrhost(var.privnet_cidr, 10) : ""
  lb_cloudscale_api_secret = var.lb_cloudscale_api_secret
  hieradata_repo_user      = var.hieradata_repo_user
  internal_vip             = cidrhost(var.privnet_cidr, 100)
  enable_proxy_protocol    = var.lb_enable_proxy_protocol
  enable_haproxy           = false
}

module "lb_api" {
  source = "./modules/cloudscale-lb"

  role        = "api"
  cluster_id  = var.cluster_id
  region      = var.region
  protocol    = "tcp"
  subnet_uuid = local.subnet_uuid
  members     = module.master.ip_addresses[*]
  ports       = [6443]

  health_check = {
    type = "https"
    path = "/readyz"
    host = "api.${local.node_name_suffix}"
  }
}

module "lb_api_int" {
  source = "./modules/cloudscale-lb"

  role        = "api-int"
  cluster_id  = var.cluster_id
  region      = var.region
  protocol    = "tcp"
  subnet_uuid = local.subnet_uuid
  members     = module.master.ip_addresses[*]
  ports       = [6443, 22623]
  allowed_cidrs = {
    22623 = [local.privnet_cidr]
  }
  // TODO(sg): Switch to .100 for api-int
  internal_vip = cidrhost(var.privnet_cidr, 99)

  health_check = {
    type = "https"
    path = "/readyz"
    host = "api.${local.node_name_suffix}"
    port = 6443
  }
}

module "lb_ingress" {
  source = "./modules/cloudscale-lb"

  role        = "ingress"
  cluster_id  = var.cluster_id
  region      = var.region
  protocol    = var.lb_enable_proxy_protocol ? "proxyv2" : "tcp"
  subnet_uuid = local.subnet_uuid
  members     = module.infra.ip_addresses[*]
  ports       = [80, 443]

  health_check = {
    type = "http"
    path = "/healthz/ready"
    host = "ingress.${local.node_name_suffix}"
    port = 1936
  }
}
