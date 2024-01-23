locals {
  cloudscale_router_vip = var.enable_router_vip ? (var.allocate_router_vip_for_lb_controller ? split("/", cloudscale_floating_ip.router_vip[0].network)[0] : split("/", module.lb.router_vip[0].network)[0]) : ""

  router_vip = var.allocate_router_vip_for_lb_controller && !var.enable_router_vip ? var.internal_router_vip : local.cloudscale_router_vip

  // TODO(sg): Figure this out with the 2025 state of the world
  router_vip_v6 = ""
}

output "dns_entries" {
  value = templatefile("${path.module}/templates/dns.zone", {
    "node_name_suffix"    = local.node_name_suffix,
    "api_vip"             = cloudscale_floating_ip.api_v4.id
    "api_vip_v6"          = cloudscale_floating_ip.api_v6.id
    "router_vip"          = local.router_vip
    "router_vip_v6"       = local.router_vip_v6
    "internal_vip"        = local.internal_vip,
    "internal_router_vip" = var.internal_router_vip,
    "masters"             = module.master.ip_addresses,
    "cluster_id"          = var.cluster_id,
  })
}

output "node_name_suffix" {
  value = local.node_name_suffix
}

output "subnet_uuid" {
  value = local.subnet_uuid
}

output "router_vip" {
  value = local.router_vip
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

output "master-machines_yml" {
  value = var.make_master_adoptable_by_provider ? module.master.machine_yml : null
}

output "master-machineset_yml" {
  value = var.make_master_adoptable_by_provider ? module.master.machineset_yml : null
}

output "infra-machines_yml" {
  value = var.make_worker_adoptable_by_provider ? module.infra.machine_yml : null
}

output "infra-machineset_yml" {
  value = var.make_worker_adoptable_by_provider ? module.infra.machineset_yml : null
}

output "worker-machines_yml" {
  value = var.make_worker_adoptable_by_provider ? module.worker.machine_yml : null
}

output "worker-machineset_yml" {
  value = var.make_worker_adoptable_by_provider ? module.worker.machineset_yml : null
}

output "additional-worker-machines_yml" {
  value = var.make_worker_adoptable_by_provider ? yamlencode({
    "apiVersion" = "v1",
    "kind"       = "List",
    "items"      = flatten(values(module.additional_worker)[*].machines)
  }) : null
}

output "additional-worker-machinesets_yml" {
  value = var.make_worker_adoptable_by_provider ? join("\n---\n", values(module.additional_worker)[*].machineset_yml) : null
}
