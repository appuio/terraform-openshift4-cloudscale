module "lb" {
  source = "git::https://github.com/appuio/terraform-modules.git//modules/vshn-lbaas-cloudscale?ref=skeleton-and-lb"

  node_name_suffix       = local.node_name_suffix
  cluster_id             = var.cluster_id
  region                 = var.region
  ssh_keys               = var.ssh_keys
  privnet_id             = cloudscale_network.privnet.id
  lb_count               = var.lb_count
  control_vshn_net_token = var.control_vshn_net_token

  router_backends          = module.infra.ip_addresses[*]
  bootstrap_node           = var.bootstrap_count > 0 ? cidrhost(var.privnet_cidr, 10) : ""
  lb_cloudscale_api_secret = var.lb_cloudscale_api_secret
  hieradata_repo_user      = var.hieradata_repo_user
  internal_vip             = cidrhost(var.privnet_cidr, 100)
}
