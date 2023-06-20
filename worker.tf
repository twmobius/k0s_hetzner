# Create worker servers

resource "hcloud_placement_group" "worker-pg" {
  count = var.worker_count > 0 ? 1 : 0
  name  = "worker-pg"
  type  = "spread"
  labels = {
    "role" : "worker"
  }
}

resource "hcloud_server" "worker" {
  count              = var.worker_count
  name               = "worker${count.index}"
  server_type        = var.worker_server_type
  placement_group_id = hcloud_placement_group.worker-pg[0].id
  image              = var.worker_server_image
  location           = var.worker_server_location
  user_data          = file("user-data")
  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  labels = {
    "role" : "worker"
  }
}

# DNS Reverse RRs
resource "hcloud_rdns" "worker_ipv4" {
  count      = var.worker_count
  server_id  = hcloud_server.worker[count.index].id
  ip_address = hcloud_server.worker[count.index].ipv4_address
  dns_ptr    = format("%s.%s", hcloud_server.worker[count.index].name, var.domain)
}

resource "hcloud_rdns" "worker_ipv6" {
  count      = var.worker_count
  server_id  = hcloud_server.worker[count.index].id
  ip_address = hcloud_server.worker[count.index].ipv6_address
  dns_ptr    = format("%s.%s", hcloud_server.worker[count.index].name, var.domain)
}
