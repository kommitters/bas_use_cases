resource "digitalocean_vpc" "bas-network" {
  name     = "bas-network"
  region   = "nyc3"
  ip_range = "10.10.10.0/24"
}
