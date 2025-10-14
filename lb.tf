resource "cloudscale_floating_ip" "router_vip" {
  count       = var.enable_router_vip && var.allocate_router_vip_for_lb_controller ? 1 : 0
  ip_version  = 4
  region_slug = var.region
  reverse_ptr = "ingress.${local.node_name_suffix}"

  tags = {
    appuio_io_vip_id = "${var.cluster_id}:ingress"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to server for migration
      server,
      # Will be handled by the cloudscale-loadbalancer-controller
      load_balancer,
    ]
  }
}

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
  internal_vip = local.internal_vip

  health_check = {
    type = "https"
    path = "/readyz"
    host = "api.${local.node_name_suffix}"
    port = 6443
  }
}
