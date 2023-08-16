module "lb" {
  source = "git::https://github.com/appuio/terraform-modules.git//modules/vshn-lbaas-cloudscale?ref=v6.7.0"

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
  use_existing_vips      = var.use_existing_vips
  enable_api_vip         = var.enable_api_vip
  enable_router_vip      = !var.allocate_router_vip_for_lb_controller && var.enable_router_vip
  enable_nat_vip         = var.enable_nat_vip

  router_backends          = var.infra_count > 0 ? module.infra.ip_addresses[*] : module.worker.ip_addresses[*]
  bootstrap_node           = var.bootstrap_count > 0 ? cidrhost(local.privnet_cidr, 10) : ""
  lb_cloudscale_api_secret = var.lb_cloudscale_api_secret
  hieradata_repo_user      = var.hieradata_repo_user
  internal_vip             = local.internal_vip
  internal_router_vip      = !var.allocate_router_vip_for_lb_controller ? var.internal_router_vip : ""
  enable_proxy_protocol    = var.lb_enable_proxy_protocol
}

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
    host = "api.${var.cluster_id}.${var.base_domain}"
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

  health_check = {
    type = "https"
    path = "/readyz"
    host = "api.${var.cluster_id}.${var.base_domain}"
  }
}

/*
resource "cloudscale_load_balancer" "api" {
  name        = "${var.cluster_id}_api"
  flavor_slug = "lb-standard"
  zone_slug   = "${var.region}1"
}

resource "cloudscale_load_balancer_pool" "api" {
  name               = "${var.cluster_id}_api"
  algorithm          = "round_robin"
  protocol           = "tcp"
  load_balancer_uuid = cloudscale_load_balancer.api.id
}

resource "cloudscale_load_balancer_pool_member" "api" {
  count         = length(module.master.ip_addresses)
  name          = "${var.cluster_id}_api-member-${count.index}"
  pool_uuid     = cloudscale_load_balancer_pool.api.id
  protocol_port = 6443
  address       = module.master.ip_addresses[count.index]
  subnet_uuid   = local.subnet_uuid
}

resource "cloudscale_load_balancer_listener" "api_k8s" {
  name          = "${var.cluster_id}_api-k8s"
  pool_uuid     = cloudscale_load_balancer_pool.api.id
  protocol      = "tcp"
  protocol_port = 6443
}

resource "cloudscale_load_balancer_health_monitor" "api" {
  pool_uuid     = cloudscale_load_balancer_pool.api.id
  type          = "https"
  http_url_path = "/readyz"
  http_host     = "api.${var.cluster_id}.${var.base_domain}"
}
*/
