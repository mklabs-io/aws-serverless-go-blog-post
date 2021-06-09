data "cloudflare_zones" "default" {
  filter {
    name = var.domain_name
  }
}
