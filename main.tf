module "deployment" {
  source = "./deployment"
  domain = "${var.domain}"
}
