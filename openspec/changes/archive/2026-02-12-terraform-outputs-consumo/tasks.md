## 1. Outputs no módulo OKE

- [x] 1.1 Expor `cluster_endpoints` e `cluster_oidc_discovery_endpoint` no `modules/oke/outputs.tf` reexportando do vendor `module.oke_cluster`
- [x] 1.2 Expor `kubernetes_version` e `cni_type` no `modules/oke/outputs.tf`
- [x] 1.3 Criar outputs agregados `subnet_ids` e `nsg_ids` no `modules/oke/outputs.tf`
- [x] 1.4 Centralizar a versão do Kubernetes em `local.kubernetes_version` no `modules/oke/main.tf` para evitar drift

## 2. Outputs no módulo Nodepools

- [x] 2.1 Criar `modules/nodepools/outputs.tf` com `system_node_pool_id` e `workload_node_pool_id`
- [x] 2.2 Adicionar outputs agregados `node_pool_ids` e `node_pool_names` (maps) para consumo por automação

## 3. Reexport nos envs dev/prod

- [x] 3.1 Atualizar `envs/dev/outputs.tf` para reexportar outputs de cluster/rede/nodepools e incluir `stack_outputs`
- [x] 3.2 Atualizar `envs/prod/outputs.tf` para reexportar outputs de cluster/rede/nodepools e incluir `stack_outputs`
- [x] 3.3 Garantir que nenhum output exponha kubeconfig (direta ou indiretamente)

## 4. Formatação e validação

- [x] 4.1 Rodar `terraform fmt -recursive` no stack
- [x] 4.2 Rodar `terraform init -backend=false -reconfigure` e `terraform validate` em `envs/dev`
- [x] 4.3 Rodar `terraform init -backend=false -reconfigure` e `terraform validate` em `envs/prod`
