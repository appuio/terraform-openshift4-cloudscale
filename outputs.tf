output "dns_entries" {
  value = templatefile("${path.module}/templates/dns.zone", {
    "node_name_suffix" = local.node_name_suffix,
    "api_vip"          = cloudscale_floating_ip.api_v4.id
    "api_vip_v6"       = cloudscale_floating_ip.api_v6.id
    "router_vip"       = cloudscale_floating_ip.ingress_v4.id
    "router_vip_v6"    = cloudscale_floating_ip.ingress_v6.id
    "internal_vip"     = module.lb_api_int.vip_v4[0]
    "masters"          = module.master.ip_addresses,
    "cluster_id"       = var.cluster_id
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
