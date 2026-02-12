## ADDED Requirements

### Requirement: Outputs for cluster metadata
The Terraform stack SHALL expose non-sensitive outputs that describe the cluster metadata for consumption by humans and automation.

#### Scenario: Read cluster metadata outputs
- **WHEN** the operator runs `terraform output` in `envs/dev` or `envs/prod`
- **THEN** the outputs SHALL include:
  - `cluster_id`
  - `cluster_endpoints`
  - `cluster_oidc_discovery_endpoint` (may be null when not enabled)
  - `kubernetes_version`
  - `cni_type`

### Requirement: Outputs for network identifiers
The Terraform stack SHALL expose non-sensitive outputs with the main network identifiers required by automation.

#### Scenario: Read subnet and NSG IDs
- **WHEN** the operator runs `terraform output -json stack_outputs`
- **THEN** the JSON SHALL include `subnet_ids` and `nsg_ids` as maps with stable keys:
  - `subnet_ids.control_plane`, `subnet_ids.workers`, `subnet_ids.pods`, `subnet_ids.pub_lb`
  - `nsg_ids.workers`, `nsg_ids.pods`

### Requirement: Outputs for node pools
The Terraform stack SHALL expose non-sensitive outputs for node pools created by `modules/nodepools`.

#### Scenario: Read node pool outputs
- **WHEN** the operator runs `terraform output -json stack_outputs`
- **THEN** the JSON SHALL include node pool identifiers and names:
  - `nodepools.ids.system`, `nodepools.ids.workload`
  - `nodepools.names.system`, `nodepools.names.workload`

### Requirement: Aggregated output for automation
The Terraform stack SHALL expose a single aggregated output that is convenient for scripts and CI/CD.

#### Scenario: Use stack_outputs for automation
- **WHEN** a script consumes `terraform output -json stack_outputs`
- **THEN** it SHALL be able to derive required identifiers without parsing multiple individual outputs.

### Requirement: Sensitive outputs are excluded
The Terraform stack MUST NOT expose kubeconfig content via outputs.

#### Scenario: Kubeconfig is not present in outputs
- **WHEN** the operator runs `terraform output -json`
- **THEN** no output SHALL contain kubeconfig content (even as `sensitive`).
