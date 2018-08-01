local k = import 'k.libsonnet';
local affinity = k.apps.v1.deployment.mixin.spec.template.spec.affinity.podAntiAffinity;
local affinityTerm = affinity.preferredDuringSchedulingIgnoredDuringExecutionType.mixin.podAffinityTermType;

{
  mixin:: {
    haSinglePodPerNode:: {
      new(labels):: affinity.withPreferredDuringSchedulingIgnoredDuringExecution(
        affinityTerm.withTopologyKey('kubernetes.io/hostname') +
        affinityTerm.mixin.labelSelector.withMatchLabels(labels)
      ),
    },
    anntotations:: {
      elbAnnotations(name, namespace, domain, sslCertificate, restricted)::
        local d = if std.endsWith(domain, '.') then domain else domain + '.';
        k.core.v1.service.mixin.metadata.withAnnotations(
          {
            'external-dns.alpha.kubernetes.io/hostname': name + '.' + namespace + '.' + d,
            'service.beta.kubernetes.io/aws-load-balancer-ssl-cert': sslCertificate,
            'service.beta.kubernetes.io/aws-load-balancer-backend-protocol': 'http',
            'service.beta.kubernetes.io/aws-load-balancer-ssl-ports': '443',
          } +
          if restricted then
            { 'service.beta.kubernetes.io/aws-load-balancer-internal': '0.0.0.0/0' }
          else {}
        ),
    },
  },
}
