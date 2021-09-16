module "hiera" {
  source = "./modules/hiera"

  router_ip_addresses      = module.infra.ip_addresses[*]
  bootstrap_node           = var.bootstrap_count > 0 ? cidrhost(var.privnet_cidr, 10) : ""
  node_name_suffix         = local.node_name_suffix
  cluster_id               = var.cluster_id
  privnet_cidr             = var.privnet_cidr
  lb_names                 = module.lb.server_names
  lb_cloudscale_api_secret = var.lb_cloudscale_api_secret
  hieradata_repo_user      = var.hieradata_repo_user
  api_vip_network          = module.lb.api_vip[0].network
  nat_vip_network          = module.lb.nat_vip[0].network
  router_vip_network       = module.lb.router_vip[0].network
}
