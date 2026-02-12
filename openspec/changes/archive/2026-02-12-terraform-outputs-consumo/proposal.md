## Why

Hoje os outputs do stack Terraform do OKE estão mínimos, o que dificulta consumo por humanos (visibilidade) e por automações (scripts/CI/CD). Precisamos padronizar e agregar saídas não-sensíveis para reduzir “cola manual” e erros operacionais.

## What Changes

- Adicionar outputs de consumo no módulo `infra-code/terraform/oci/oke-cluster-stack/modules/oke`:
  - endpoints do cluster (public/private)
  - OIDC discovery endpoint (quando habilitado)
  - versão do Kubernetes e CNI configurados
  - mapas agregados com IDs de subnets e NSGs mais importantes
- Adicionar outputs no módulo `infra-code/terraform/oci/oke-cluster-stack/modules/nodepools`:
  - OCIDs e nomes dos node pools (system/workload), incluindo mapa agregado
- Reexportar outputs nos envs `infra-code/terraform/oci/oke-cluster-stack/envs/dev` e `envs/prod`:
  - outputs individuais “human-friendly”
  - output agregado `stack_outputs` (map) para consumo por automação via `terraform output -json`
- Não expor kubeconfig como output (evitar material sensível em pipelines).
- Não derivar IP público do LB do ingress via Terraform (ficará como operação via `kubectl`/documentação).

## Capabilities

### New Capabilities
- `terraform-stack-outputs`: Outputs padronizados e agregados (não-sensíveis) para consumo humano e automação no stack OKE/OCI.

### Modified Capabilities
- (nenhuma)

## Impact

- Arquivos Terraform afetados no stack:
  - `infra-code/terraform/oci/oke-cluster-stack/modules/oke/*`
  - `infra-code/terraform/oci/oke-cluster-stack/modules/nodepools/*`
  - `infra-code/terraform/oci/oke-cluster-stack/envs/dev/*`
  - `infra-code/terraform/oci/oke-cluster-stack/envs/prod/*`
- Usuários/CI passam a consumir preferencialmente `stack_outputs` via `terraform output -json`.
