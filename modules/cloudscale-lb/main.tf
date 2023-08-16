resource "cloudscale_load_balancer" "lb" {
  name        = "${var.cluster_id}_${var.role}"
  flavor_slug = "lb-standard"
  zone_slug   = "${var.region}1"
}

resource "cloudscale_load_balancer_pool" "lb" {
  name               = "${var.cluster_id}_${var.role}"
  algorithm          = "round_robin"
  protocol           = var.protocol
  load_balancer_uuid = cloudscale_load_balancer.lb.id
}

resource "cloudscale_load_balancer_pool_member" "lb" {
  count         = length(var.members)*length(var.ports)
  name          = "${var.cluster_id}_api-member-${count.index}"
  pool_uuid     = cloudscale_load_balancer_pool.lb.id
  protocol_port = var.ports[count.index%var.ports]
  address       = var.members[count.index/var.ports]
  subnet_uuid   = var.subnet_uuid
  monitor_port  = var.health_check.port
}

resource "cloudscale_load_balancer_listener" "lb" {
  count         = len(var.ports)
  name          = "${var.cluster_id}_${var.role}_${var.ports[count.index]}"
  pool_uuid     = cloudscale_load_balancer_pool.lb.id
  protocol      = var.protocol
  protocol_port = var.ports[count.index]
}

resource "cloudscale_load_balancer_health_monitor" "lb" {
  pool_uuid     = cloudscale_load_balancer_pool.lb.id
  type          = var.health_check.type
  http_url_path = var.health_check.path
  http_host     = var.health_check.host
}
