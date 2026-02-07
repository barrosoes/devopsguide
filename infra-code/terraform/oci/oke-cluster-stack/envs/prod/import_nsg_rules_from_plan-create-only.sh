#!/usr/bin/env bash
set -euo pipefail

PLAN_FILE="${1:-tfplan}"

command -v terraform >/dev/null
command -v jq >/dev/null
command -v oci >/dev/null

rules_json="$(
  terraform show -json "$PLAN_FILE" | jq -c '
    [ .resource_changes[]
      | select(.type=="oci_core_network_security_group_security_rule")
      | {
          actions: .change.actions,
          nsg:  .change.after.network_security_group_id,
          addr: .address,
          desc: (.change.after.description // ""),
          dir:  .change.after.direction
        }
    ]
  '
)"

if [[ "$(jq -r 'length' <<<"$rules_json")" == "0" ]]; then
  echo "Nenhuma regra NSG encontrada no plan ($PLAN_FILE)."
  exit 0
fi

create_only_json="$(jq -c '[ .[] | select(.actions == ["create"]) ]' <<<"$rules_json")"
replacement_json="$(jq -c '[ .[] | select((.actions|index("delete")) and (.actions|index("create"))) ]' <<<"$rules_json")"
update_json="$(jq -c '[ .[] | select(.actions == ["update"]) ]' <<<"$rules_json")"

print_grouped() {
  local title="$1"
  local json="$2"
  if [[ "$(jq -r 'length' <<<"$json")" == "0" ]]; then
    return 0
  fi
  echo "========== $title =========="
  jq -r '
    sort_by(.nsg, .dir, .desc, .addr)
    | group_by(.nsg)
    | .[]
    | "NSG: \(.[0].nsg)\n"
      + (map("  - [\(.dir)] \(.desc)\n    \(.addr)") | join("\n"))
      + "\n"
  ' <<<"$json"
}

print_grouped "CREATE-ONLY (candidatas a import)" "$create_only_json"
print_grouped "REPLACEMENT (delete+create)"        "$replacement_json"
print_grouped "UPDATE (in-place)"                 "$update_json"

# --- Parte OCI + import: SOMENTE create-only ---
if [[ "$(jq -r 'length' <<<"$create_only_json")" == "0" ]]; then
  echo "Nenhuma regra CREATE-ONLY; nada para importar."
  exit 0
fi

echo "========== OCI lookup (somente CREATE-ONLY) =========="
jq -r 'sort_by(.nsg) | group_by(.nsg) | .[] | .[0].nsg' <<<"$create_only_json" | while IFS= read -r nsg; do
  echo
  echo "NSG: $nsg"
  oci_json="$(oci network nsg rules list --nsg-id "$nsg" --all --output json)"

  jq -c --arg nsg "$nsg" '.[] | select(.nsg==$nsg)' <<<"$create_only_json" | while IFS= read -r r; do
    desc="$(jq -r '.desc' <<<"$r")"
    dir="$(jq -r '.dir'  <<<"$r")"
    addr="$(jq -r '.addr' <<<"$r")"

    # match exato (recomendado). Se quiser contains, te mando a variante.
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
echo "========== terraform import (somente CREATE-ONLY) =========="
jq -r 'sort_by(.nsg) | group_by(.nsg) | .[] | .[0].nsg' <<<"$create_only_json" | while IFS= read -r nsg; do
  oci_json="$(oci network nsg rules list --nsg-id "$nsg" --all --output json)"

  jq -c --arg nsg "$nsg" '.[] | select(.nsg==$nsg)' <<<"$create_only_json" | while IFS= read -r r; do
    desc="$(jq -r '.desc' <<<"$r")"
    dir="$(jq -r '.dir'  <<<"$r")"

    id="$(jq -r --arg desc "$desc" --arg dir "$dir" '
      [ .data[]
        | select(.description==$desc and .direction==$dir)
        | .id
      ][0] // empty
    ' <<<"$oci_json")"

    [[ -z "$id" ]] && continue

    addr_sh="$(jq -r '.addr | @sh' <<<"$r")"
    import_id="networkSecurityGroups/$nsg/securityRules/$id"
    import_id_sh="$(jq -nr --arg s "$import_id" '$s|@sh')"

    echo "terraform import $addr_sh $import_id_sh"
  done
done
