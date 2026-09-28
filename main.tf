locals {
  cluster_name          = var.cluster_name != "" ? var.cluster_name : var.cluster_id
  node_name_suffix      = "${local.cluster_name}.${var.base_domain}"
  create_privnet_subnet = var.subnet_uuid == "" ? 1 : 0
  subnet_uuid           = var.subnet_uuid == "" ? cloudscale_subnet.privnet_subnet[0].id : var.subnet_uuid
  privnet_uuid          = local.create_privnet_subnet > 0 ? cloudscale_network.privnet[0].id : data.cloudscale_subnet.privnet_subnet[0].network_uuid
  privnet_cidr          = local.create_privnet_subnet > 0 ? var.privnet_cidr : data.cloudscale_subnet.privnet_subnet[0].cidr
  worker_volume_size_gb = var.worker_volume_size_gb == 0 ? var.default_volume_size_gb : var.worker_volume_size_gb
  internal_vip          = var.internal_vip != "" ? var.internal_vip : cidrhost(local.privnet_cidr, 100)
  gateway_address       = cidrhost(local.privnet_cidr, 1)

  create_puppet_lbs = !var.allocate_router_vip_for_lb_controller || !var.enable_api_lbaas || !var.enable_cloudscale_router
}

resource "cloudscale_network" "privnet" {
  count                   = local.create_privnet_subnet
  name                    = "privnet-${var.cluster_id}"
  zone_slug               = "${var.region}1"
  auto_create_ipv4_subnet = false
}

resource "cloudscale_subnet" "privnet_subnet" {
  count           = local.create_privnet_subnet
  network_uuid    = local.privnet_uuid
  cidr            = local.privnet_cidr
  gateway_address = local.gateway_address
}

data "cloudscale_subnet" "privnet_subnet" {
  count = var.subnet_uuid == "" ? 0 : 1
  id    = var.subnet_uuid
}

resource "cloudscale_router" "gateway" {
  count = var.enable_cloudscale_router ? 1 : 0

  # NOTE(sg): Using a fqdn as the gateway name automatically configures a DNS
  # PTR record for the gateway public IP at cloudscale.
  name             = "egress.${local.node_name_suffix}"
  zone_slug        = "${var.region}1"
  internet_gateway = var.enable_nat_vip
}

resource "cloudscale_interface" "gateway_clusternet" {
  count = var.enable_cloudscale_router ? 1 : 0

  router_uuid  = cloudscale_router.gateway[0].id
  network_uuid = local.privnet_uuid

  addresses {
    subnet_uuid = local.subnet_uuid
    address     = local.gateway_address
  }
}
