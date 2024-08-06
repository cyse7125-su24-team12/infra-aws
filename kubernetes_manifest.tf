resource "kubernetes_manifest" "istio_ingress_gateway" {
  depends_on = [module.eks]
  provider   = kubernetes.kubernetes-eks
  # namespace  = kubernetes_namespace.prometheus_graphana_ns.metadata[0].name
  manifest = yamldecode(file("${path.module}/manifests/ingress-gateway.yaml"))
}

resource "kubernetes_manifest" "virtual_service_grafana" {
  depends_on = [module.eks]
  provider   = kubernetes.kubernetes-eks
  manifest   = yamldecode(file("${path.module}/manifests/virtual-service-grafana.yaml"))
}

resource "kubernetes_manifest" "certificate_issuer" {
  depends_on = [module.eks, helm_release.cert_manager]
  provider   = kubernetes.kubernetes-eks
  manifest   = yamldecode(file("${path.module}/manifests/certificate-issuer.yaml"))
}


resource "kubernetes_manifest" "certificate_values" {
  depends_on = [module.eks, helm_release.cert_manager, kubernetes_manifest.certificate_issuer]
  provider   = kubernetes.kubernetes-eks
  manifest   = yamldecode(file("${path.module}/manifests/certificate-values.yaml"))
}

resource "kubernetes_manifest" "cert_mgr_role" {
  depends_on = [module.eks, helm_release.cert_manager]
  provider   = kubernetes.kubernetes-eks
  manifest   = yamldecode(file("${path.module}/manifests/cert-mgr-role.yaml"))
}

resource "kubernetes_manifest" "cert_mgr_rolebinding" {
  depends_on = [module.eks, helm_release.cert_manager, kubernetes_manifest.cert_mgr_role]
  provider   = kubernetes.kubernetes-eks
  manifest   = yamldecode(file("${path.module}/manifests/cert-mgr-rolebinding.yaml"))
}
