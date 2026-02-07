## Stack OKE (OCI) — Terraform multi-ambiente (DEV + PROD)

Este diretório provisiona um **cluster Kubernetes no Oracle Kubernetes Engine (OKE)** com **dois ambientes** (`dev` e `prod`) usando Terraform.

### Sumário

- [Visão geral](#visão-geral)
- [Estrutura do projeto](#estrutura-do-projeto)
- [O que é provisionado](#o-que-é-provisionado)
- [Requisitos](#requisitos)
- [Credenciais e autenticação](#credenciais-e-autenticação)
- [Backend remoto (Object Storage S3-compat)](#backend-remoto-object-storage-s3-compat)
- [Como usar (local)](#como-usar-local)
- [Ambientes e variáveis](#ambientes-e-variáveis)
- [Outputs](#outputs)
- [Módulos](#módulos)
- [Pós-provisionamento (kubeconfig e addons)](#pós-provisionamento-kubeconfig-e-addons)
- [CI/CD (GitHub Actions e GitLab CI)](#cicd-github-actions-e-gitlab-ci)
- [Pontos de atenção](#pontos-de-atenção)
- [Troubleshooting](#troubleshooting)

---

## Visão geral

- **Cloud**: Oracle Cloud Infrastructure (OCI)
- **Kubernetes**: OKE (Enhanced cluster)
- **Região (hardcoded)**: `sa-saopaulo-1`
- **State remoto**: OCI Object Storage via **backend `s3` (compatível)** com endpoint da OCI
- **Ambientes**: `envs/dev` e `envs/prod`

---

## Estrutura do projeto

```text
.
├── addons/
│   ├── app-ingress-arbtitech.yaml
│   ├── cert-manager.yaml
│   ├── clusterissuer-letsencrypt.yaml
│   ├── ingress-nginx.yaml
│   └── metrics-server.yaml
├── envs/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── terraform.tfvars
│       ├── terraform.tfvars.example
│       └── variables.tf
├── modules/
│   ├── network/     # módulo auxiliar (VCN/subnets) — atualmente não é usado pelos envs
│   ├── nodepools/   # cria node pools "system" e "workload"
│   └── oke/         # cria cluster OKE e VCN/subnets via módulo oficial
├── .github/workflows/terraform.yml
└── .gitlab-ci.yml
```

---

## O que é provisionado

- **Cluster OKE Enhanced** via `oracle-terraform-modules/oke/oci` (ver `modules/oke`)
- **VCN + subnets** criadas pelo módulo OKE (um “one-step apply”)
  - Control Plane (`cp`)
  - Workers (`workers`)
  - Pods (`pods`) (relevante para CNI VCN-Native)
  - Public LB (`pub_lb`)
- **Endpoint do Control Plane público**, restrito por CIDRs permitidos
- **Node pools** via `modules/nodepools`
  - `system-pool` e `workload-pool`
  - Shape: `VM.Standard.E4.Flex` (2 OCPUs / 16 GB RAM, boot 50 GB)
  - Seleção de imagem: tenta auto-selecionar via `oci_containerengine_node_pool_option` e, se falhar, exige `node_image_id`

---

## Requisitos

- **Terraform**: `>= 1.5.0` (ver `envs/*/provider.tf`)
- **Provider OCI**: `>= 5.0.0`
- **Conta/tenancy OCI** com permissões para:
  - OKE (cluster + node pools)
  - Networking (VCN/subnets, gateways, etc.)
  - Object Storage (bucket do state)
- **OCI CLI** (opcional, mas recomendado) para gerar `kubeconfig`
- **kubectl** (para validar cluster e aplicar addons)

---

## Credenciais e autenticação

### Provider OCI (Terraform)

Os providers `oci` são declarados sem parâmetros de auth além de região; então o Terraform vai usar o método padrão do provider (geralmente `~/.oci/config` + profile `DEFAULT`, ou variáveis de ambiente suportadas pelo SDK).

- **Recomendado (local)**: configurar `~/.oci/config` e a chave privada em `~/.oci/`
- **Em CI/CD**: você precisará injetar/criar o `~/.oci/config` e a chave privada durante o job (ver seção [CI/CD](#cicd-github-actions-e-gitlab-ci))

---

## Backend remoto (Object Storage S3-compat)

Os ambientes usam backend `s3` apontando para o endpoint compatível da OCI:

- `envs/dev/backend.tf`
  - **bucket**: `tfstate-oke`
  - **key**: `dev/terraform.tfstate`
  - **endpoint**: `https://gr5ugxwrsywe.compat.objectstorage.sa-saopaulo-1.oraclecloud.com`
- `envs/prod/backend.tf`
  - **bucket**: `tfstate-oke-prod`
  - **key**: `prod/terraform.tfstate`
  - **endpoint**: `https://gr5ugxwrsywe.compat.objectstorage.sa-saopaulo-1.oraclecloud.com`

### Como autenticar no backend `s3`

O backend `s3` do Terraform espera credenciais no padrão AWS. Para OCI Object Storage (compat), isso normalmente significa usar **Customer Secret Key** do usuário OCI e exportar:

```bash
export AWS_ACCESS_KEY_ID="<customer-secret-key-access>"
export AWS_SECRET_ACCESS_KEY="<customer-secret-key-secret>"
```

> Observação: o `backend.tf` tem `access_key`/`secret_key` comentados; o caminho mais comum é usar variáveis de ambiente.

### Locking do state

OCI Object Storage **não oferece locking nativo** como o DynamoDB (AWS). Este repositório mitiga isso **serializando `apply`** via:

- GitHub Actions: `concurrency.group` (`terraform-dev` / `terraform-prod`)
- GitLab CI: `resource_group` (`terraform-dev` / `terraform-prod`)

Recomendação: habilitar **Object Versioning** nos buckets de state.

---

## Como usar (local)

### DEV

```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

### PROD

```bash
cd envs/prod
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

### Destroy (cuidado)

```bash
cd envs/dev   # ou envs/prod
terraform destroy
```

---

## Ambientes e variáveis

### `envs/dev`

Variáveis em `envs/dev/variables.tf` e exemplo em `envs/dev/terraform.tfvars.example`:

- **`compartment_id`** (string, obrigatório): OCID do compartment
- **`ssh_public_key_path`** (string, obrigatório): caminho para chave pública SSH
- **`vcn_cidr`** (string, default `10.20.0.0/16`): CIDR da VCN
- **`home_region`** (string, default `sa-saopaulo-1`): região home da tenancy
- **`tenancy_ocid`** (string, opcional): OCID da tenancy (para listar Availability Domains)
- **`availability_domain`** (string, opcional): AD explícito para os node pools

### `envs/prod`

Variáveis em `envs/prod/variables.tf` e exemplo em `envs/prod/terraform.tfvars.example`:

- **`compartment_id`** (string, obrigatório)
- **`ssh_public_key_path`** (string, obrigatório)
- **`vcn_cidr`** (string, default `10.10.0.0/16`)
- **`home_region`** (string, default `sa-saopaulo-1`)
- **`tenancy_ocid`** (string, opcional)
- **`availability_domain`** (string, opcional)
- **`node_image_id`** (string, opcional): OCID de imagem OKE-ready (usado se a seleção automática falhar)

---

## Outputs

Ambos ambientes expõem:

- **`cluster_id`**: OCID do cluster OKE

(ver `envs/dev/outputs.tf` e `envs/prod/outputs.tf`)

---

## Módulos

### `modules/oke`

- Fonte: `oracle-terraform-modules/oke/oci` versão **5.3.2**
- Cria:
  - Cluster Enhanced
  - VCN/subnets via `create_vcn = true`
  - Control plane público (`control_plane_is_public = true`) com allowlist de CIDRs
- Variáveis relevantes:
  - **`control_plane_allowed_cidrs`** (default `["177.221.120.243/32"]`)
  - **`cni_type`** (default `"npn"` = VCN-Native / `OCI_VCN_IP_NATIVE`)
  - **`kubernetes_version`** está fixado em `v1.34.2`

### `modules/nodepools`

Cria `system-pool` e `workload-pool` com:

- Seleção automática de AD (ou `availability_domain`)
- Seleção automática de imagem OKE-ready (ou `node_image_id`)
- **Pré-condição**:
  - Se `cni_type == "npn"`, precisa de `pods_subnet_id` (subnet de pods)

### `modules/network` (não usado pelos envs)

Existe um módulo `modules/network` baseado em `oracle-terraform-modules/vcn/oci` (v3.6.0), mas **os envs atuais não o referenciam** (o módulo OKE já cria VCN/subnets).

---

## Pós-provisionamento (kubeconfig e addons)

### Gerar kubeconfig

Após o `apply`, pegue o `cluster_id`:

```bash
cd envs/prod   # ou envs/dev
terraform output -raw cluster_id
```

Depois gere o kubeconfig:

```bash
oci ce cluster create-kubeconfig \
  --cluster-id "<cluster_id>" \
  --file "$HOME/.kube/config" \
  --region sa-saopaulo-1
```

Validar:

```bash
kubectl get nodes
```

### Addons (`addons/`)

Os manifests neste diretório são **exemplos/base**:

- `addons/ingress-nginx.yaml`: atualmente cria apenas o Namespace `ingress-nginx`
- `addons/cert-manager.yaml`: atualmente cria apenas o Namespace `cert-manager`
- `addons/clusterissuer-letsencrypt.yaml`: `ClusterIssuer` ACME (Let’s Encrypt)
- `addons/app-ingress-arbtitech.yaml`: exemplo de `Ingress` com TLS para `app.arbtitech.com`
- `addons/metrics-server.yaml`: placeholder

Aplicar (ajuste conforme seu padrão — Helm/Kustomize/etc.):

```bash
kubectl apply -f addons/metrics-server.yaml
kubectl apply -f addons/ingress-nginx.yaml
kubectl apply -f addons/cert-manager.yaml
kubectl apply -f addons/clusterissuer-letsencrypt.yaml
```

---

## CI/CD (GitHub Actions e GitLab CI)

### O que existe hoje

- `.github/workflows/terraform.yml`
  - Jobs: `validate` → `plan-dev`/`plan-prod` → `apply-dev`/`apply-prod`
  - `apply` serializado via `concurrency.group`
  - `apply-prod` roda em environment `prod` (permite approval via GitHub Environments)
- `.gitlab-ci.yml`
  - Stages: validate → plan → apply_dev/apply_prod
  - `apply_*` manual e serializado via `resource_group`

### O que você ainda precisa configurar

Para o CI funcionar de ponta a ponta, você precisa garantir que:

- **Credenciais OCI do provider** estejam disponíveis no job (ex.: criar `~/.oci/config` e a chave privada durante o pipeline).
- **Credenciais do backend `s3`** estejam exportadas (ex.: `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` para o endpoint compatível da OCI).

---

## Pontos de atenção

### 1) CIDRs permitidos no Control Plane

O módulo `modules/oke` tem allowlist padrão em `control_plane_allowed_cidrs` com um IP `/32`. **Troque para o seu IP** (ou range corporativo) para não se bloquear.

### 2) CNI VCN-Native (`npn`) e subnet de pods

O `cni_type` padrão é `"npn"` (VCN-Native). Nesse modo, os node pools exigem uma **subnet de pods** (`pods_subnet_id`). Se ela não for informada, o módulo `modules/nodepools` falha por precondition.

### 3) “Autoscaler”

O repositório menciona autoscaler, mas o Terraform atual cria node pools com `size` fixo. Se você quiser autoscaling nativo de node pool no OKE, isso exige configuração específica (fora do escopo destes manifests base).

---

## Troubleshooting

### `terraform init` falha no backend

- Verifique se o bucket existe (`tfstate-oke` ou `tfstate-oke-prod`)
- Verifique `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (Customer Secret Key no OCI)
- Confirme o `endpoint` no `backend.tf`

### Falha ao criar node pools (imagem)

Se a seleção automática de imagem falhar, informe `node_image_id` em `terraform.tfvars` (OCID de uma imagem OKE-ready na região).

### Falha por `pods_subnet_id` (CNI `npn`)

Se estiver usando `cni_type = "npn"`, garanta que `pods_subnet_id` esteja sendo passado ao `modules/nodepools`.

### Listar versões suportadas do OKE

```bash
oci ce cluster-option get --region sa-saopaulo-1
```

