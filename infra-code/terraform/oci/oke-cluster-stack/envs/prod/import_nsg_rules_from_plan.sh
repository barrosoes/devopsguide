#!/usr/bin/env bash
set -euo pipefail

PLAN_FILE="${1:-tfplan}"

command -v terraform >/dev/null
command -v jq >/dev/null
command -v oci >/dev/null

creates_json="$(
  terraform show -json "$PLAN_FILE" | jq -c '
    [ .resource_changes[]
      | select(.type=="oci_core_network_security_group_security_rule")
      | select(.change.actions | index("create"))
      | {
          nsg:  .change.after.network_security_group_id,
          addr: .address,
          desc: (.change.after.description // ""),
          dir:  .change.after.direction
        }
    ]
    | sort_by(.nsg, .dir, .desc, .addr)
  '
)"

if [[ "$(jq -r 'length' <<<"$creates_json")" == "0" ]]; then
  echo "Nenhuma regra NSG com action=create encontrada no plan ($PLAN_FILE)."
  exit 0
fi

echo "========== (1) Regras do tfplan (agrupadas por NSG) =========="
jq -r '
  group_by(.nsg)
  | .[]
  | "NSG: \(.[0].nsg)\n"
    + (map("  - [\(.dir)] \(.desc)\n    \(.addr)") | join("\n"))
    + "\n"
' <<<"$creates_json"

echo "========== (2) OCI: ids por description/direction =========="
jq -r 'group_by(.nsg) | .[] | .[0].nsg' <<<"$creates_json" | while IFS= read -r nsg; do
  echo
  echo "NSG: $nsg"

  oci_json="$(oci network nsg rules list --nsg-id "$nsg" --all --output json)"

  jq -c --arg nsg "$nsg" '.[] | select(.nsg==$nsg)' <<<"$creates_json" | while IFS= read -r r; do
    desc="$(jq -r '.desc' <<<"$r")"
    dir="$(jq -r '.dir'  <<<"$r")"
    addr="$(jq -r '.addr' <<<"$r")"

    # match exato (mais seguro que contains)
    id="$(jq -r --arg desc "$desc" --arg dir "$dir" '
      [ .data[]
        | select(.description==$desc and .direction==$dir)
        | .id
      ][0] // empty
    ' <<<"$oci_json")"

    if [[ -z "$id" ]]; then
      echo "  NOT FOUND: [$dir] $desc"
      echo "    addr: $addr"
      continue
    fi

    echo "  FOUND: [$dir] $desc"
    echo "    id: $id"
  done
done

echo
echo "========== (3) Comandos terraform import (prontos pra copiar/rodar) =========="
jq -r 'group_by(.nsg) | .[] | .[0].nsg' <<<"$creates_json" | while IFS= read -r nsg; do
  oci_json="$(oci network nsg rules list --nsg-id "$nsg" --all --output json)"

  jq -c --arg nsg "$nsg" '.[] | select(.nsg==$nsg)' <<<"$creates_json" | while IFS= read -r r; do
    desc="$(jq -r '.desc' <<<"$r")"
    dir="$(jq -r '.dir'  <<<"$r")"
    addr_sh="$(jq -r '.addr | @sh' <<<"$r")"

    id="$(jq -r --arg desc "$desc" --arg dir "$dir" '
      [ .data[]
        | select(.description==$desc and .direction==$dir)
        | .id
      ][0] // empty
    ' <<<"$oci_json")"

    [[ -z "$id" ]] && continue

    import_id="networkSecurityGroups/$nsg/securityRules/$id"
    import_id_sh="$(jq -nr --arg s "$import_id" '$s|@sh')"

    echo "terraform import $addr_sh $import_id_sh"
  done
done
