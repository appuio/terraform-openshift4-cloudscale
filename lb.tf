module "lb_api" {
  source = "./modules/cloudscale-lb"

  role         = "api"
  cluster_id   = var.cluster_id
  lb_flavor    = var.lbaas_flavor
  region       = var.region
  protocol     = "tcp"
  subnet_uuid  = local.subnet_uuid
  members      = module.master.ip_addresses[*]
  bootstrap_ip = var.bootstrap_count > 0 ? cidrhost(local.privnet_cidr, 10) : ""
  ports        = [6443]

  health_check = {
    type = "https"
    path = "/readyz"
    host = "api.${local.node_name_suffix}"
  }
}

resource "cloudscale_floating_ip" "api_v4" {
  load_balancer = module.lb_api.lb_id
  ip_version    = 4
  reverse_ptr   = "api.${local.node_name_suffix}"
}

resource "cloudscale_floating_ip" "api_v6" {
  load_balancer = module.lb_api.lb_id
  ip_version    = 6
  reverse_ptr   = "api.${local.node_name_suffix}"
}

module "lb_api_int" {
  source = "./modules/cloudscale-lb"

  role         = "api-int"
  cluster_id   = var.cluster_id
  lb_flavor    = var.lbaas_flavor
  region       = var.region
  protocol     = "tcp"
  subnet_uuid  = local.subnet_uuid
  members      = module.master.ip_addresses[*]
  bootstrap_ip = var.bootstrap_count > 0 ? cidrhost(local.privnet_cidr, 10) : ""
  ports        = [6443, 22623]
  allowed_cidrs = {
    22623 = [local.privnet_cidr]
  }
  internal_vip = cidrhost(var.privnet_cidr, 100)

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
  lb_flavor   = var.lbaas_flavor
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

resource "cloudscale_floating_ip" "ingress_v4" {
  load_balancer = module.lb_ingress.lb_id
  ip_version    = 4
  reverse_ptr   = "ingress.${local.node_name_suffix}"
}

resource "cloudscale_floating_ip" "ingress_v6" {
  load_balancer = module.lb_ingress.lb_id
  ip_version    = 6
  reverse_ptr   = "ingress.${local.node_name_suffix}"
}
