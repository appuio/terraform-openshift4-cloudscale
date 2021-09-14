output "api_vip" {
  value = cloudscale_floating_ip.api_vip
}

output "nat_vip" {
  value = cloudscale_floating_ip.nat_vip
}

output "router_vip" {
  value = cloudscale_floating_ip.router_vip
}

output "server_names" {
  value = random_id.lb
}

output "servers" {
  value = cloudscale_server.lb
}

output "hieradata_mr_url" {
  value = var.lb_count > 0 ? data.local_file.hieradata_mr_url[0].content : ""
}
