output "vip_v4" {
  value = matchkeys(cloudscale_load_balancer.lb.vip_addresses[*].address, cloudscale_load_balancer.lb.vip_addresses[*].version, [4])
}

output "vip_v6" {
  value = matchkeys(cloudscale_load_balancer.lb.vip_addresses[*].address, cloudscale_load_balancer.lb.vip_addresses[*].version, [6])
}
