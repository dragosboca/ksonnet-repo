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
  },
}
