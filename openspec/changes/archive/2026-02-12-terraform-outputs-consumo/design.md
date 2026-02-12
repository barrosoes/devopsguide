## Context

O stack Terraform em `infra-code/terraform/oci/oke-cluster-stack` provisiona um cluster OKE (via módulo vendorizado `modules/vendor/terraform-oci-oke`) e node pools adicionais (via `modules/nodepools`). Hoje os envs (`envs/dev` e `envs/prod`) expõem poucos outputs, tornando difícil:

- Automatizar dependências (ex.: anexar NSGs/Subnets em módulos externos, scripts de pós-provisionamento)
- Inspecionar rapidamente IDs críticos (cluster/subnets/NSGs/node pools)

O módulo vendor já possui outputs úteis como `cluster_endpoints` e `cluster_oidc_discovery_endpoint`, e também possui `cluster_kubeconfig` sob `output_detail`, mas este change não deve expor kubeconfig em outputs por motivos de segurança.

## Goals / Non-Goals

**Goals:**
- Fornecer outputs **não sensíveis** e orientados a consumo humano e automação:
  - Endpoints do cluster e OIDC discovery endpoint (quando habilitado)
  - Versão do Kubernetes e CNI configurados
  - IDs de subnets e NSGs importantes em formato agregado (maps)
  - IDs e nomes de node pools em formato agregado
- Reexportar outputs nos envs `dev` e `prod` para consumo externo via `terraform output` e `terraform output -json`.
- Garantir validação (`terraform fmt` e `terraform validate`) sem exigir acesso ao backend remoto de state (uso de `-backend=false` em validação local).

**Non-Goals:**
- Expor kubeconfig via outputs (mesmo como `sensitive`).
- Derivar IP público do Load Balancer do ingress via data sources OCI (fica como operação via `kubectl`/documentação).
- Alterar recursos provisionados (somente adicionar outputs e refatoração mínima para expor valores já existentes).

## Decisions

- **Outputs agregados em maps**: além de outputs “unitários”, adicionar mapas como `subnet_ids`, `nsg_ids`, `node_pool_ids`, `node_pool_names` e `stack_outputs` para facilitar consumo por automação (JSON).
  - Alternativa: manter outputs apenas unitários. Rejeitado por piorar consumo programático (scripts/CI precisam montar estrutura manualmente).

- **Reexport no nível do env**: `envs/dev/outputs.tf` e `envs/prod/outputs.tf` devem reexportar tudo que é necessário, para que consumidores não dependam de caminhos internos de módulos.
  - Alternativa: consumir diretamente outputs dos módulos. Rejeitado por acoplamento a estrutura interna.

- **Kubernetes version como local no wrapper**: centralizar a versão no `modules/oke/main.tf` em `local.kubernetes_version` para ser usada tanto na chamada do módulo vendor quanto exposta em output.
  - Alternativa: duplicar string no output. Rejeitado por risco de drift.

## Risks / Trade-offs

- **[Risco] Quebra de compatibilidade de consumers existentes** → Mitigação: manter outputs existentes (`cluster_id`, subnets e NSGs unitários) e apenas adicionar novos outputs.
- **[Risco] Outputs muito grandes/verbosos** (especialmente endpoints) → Mitigação: manter apenas dados essenciais e não incluir kubeconfig.
- **[Risco] Validação local sem backend** pode mascarar problemas de auth no backend remoto → Mitigação: documentar que `terraform plan/apply` ainda requer credenciais do backend S3-compat (OCI Object Storage).
