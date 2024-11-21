module "deployment" {
  source = "./modules/deployment"
  domain = "${var.domain}"
}
