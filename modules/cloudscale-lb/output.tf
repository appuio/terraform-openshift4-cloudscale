output "lb_id" {
  value = var.create ? cloudscale_load_balancer.lb[0].id : ""
}

output "vip_v4" {
  value = var.create ? matchkeys(cloudscale_load_balancer.lb[0].vip_addresses[*].address, cloudscale_load_balancer.lb[0].vip_addresses[*].version, [4]) : []
}

output "vip_v6" {
  value = var.create ? matchkeys(cloudscale_load_balancer.lb[0].vip_addresses[*].address, cloudscale_load_balancer.lb[0].vip_addresses[*].version, [6]) : []
}
