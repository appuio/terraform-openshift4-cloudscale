output "dns_entries" {
  value = templatefile("${path.module}/templates/dns.zone", {
    "node_name_suffix" = local.node_name_suffix,
    "api_vip"          = var.lb_count != 0 ? split("/", module.lb.api_vip.network)[0] : ""
    "router_vip"       = var.lb_count != 0 ? split("/", module.lb.router_vip.network)[0] : ""
    "egress_vip"       = var.lb_count != 0 ? split("/", module.lb.nat_vip.network)[0] : ""
    "internal_vip"     = cidrhost(local.privnet_cidr, 100),
    "masters"          = module.master.ip_addresses,
    "cluster_id"       = var.cluster_id,
    "lbs"              = module.lb.public_ipv4_addresses,
    "lb_hostnames"     = module.lb.server_names
  })
}

output "node_name_suffix" {
  value = local.node_name_suffix
}

output "subnet_uuid" {
  value = local.subnet_uuid
}

output "region" {
  value = var.region
}

output "cluster_id" {
  value = var.cluster_id
}

output "ignition_ca" {
  value = var.ignition_ca
}

output "api_int" {
  value = "api-int.${local.node_name_suffix}"
}

output "hieradata_mr" {
  value = module.lb.hieradata_mr_url
}
