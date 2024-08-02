data "aws_route53_zone" "graphane_zone" {
  name = "shyammylai.me"
  private_zone = false
}

resource "aws_route53_record" "cname_graphana_record" {
    depends_on = [ data.kubernetes_service.istio_gateway_service_data ]
    zone_id = data.aws_route53_zone.graphane_zone.zone_id
    name    = "grafana.shyammylai.me"
    type    = "CNAME"
    ttl     = "60"
    records = [data.kubernetes_service.istio_gateway_service_data.status.0.load_balancer.0.ingress.0.hostname]
}
