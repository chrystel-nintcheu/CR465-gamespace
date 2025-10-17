#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <matricule> [vm-name]"
  echo "Exemple: $0 p123456 ubuntuDockerVM"
  exit 1
fi

MATRICULE=$1
VM_NAME=${2:-ubuntuVM}
RESOURCE_GROUP="rg-cr465gamespace-$MATRICULE"

echo "Groupe de ressources: $RESOURCE_GROUP"
echo "VM: $VM_NAME"

# Vérifier que la VM existe
if ! az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" &>/dev/null; then
  echo "Erreur: VM '$VM_NAME' introuvable dans le groupe '$RESOURCE_GROUP'."
  az vm list --resource-group "$RESOURCE_GROUP" --output table || true
  exit 1
fi

# Récupérer infos sur la VM
OS_DISK=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "storageProfile.osDisk.name" -o tsv || true)
DATA_DISKS=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "storageProfile.dataDisks[].name" -o tsv || true)
NIC_IDS=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "networkProfile.networkInterfaces[].id" -o tsv || true)

echo "OS disk: ${OS_DISK:-<none>}"
echo "Data disks: ${DATA_DISKS:-<none>}"
echo "NIC ids:"
echo "$NIC_IDS" || true

# Confirmation (sécurise les suppressions par erreur)
read -p "Confirmer la suppression de la VM et des ressources associées ? (yes/NO): " CONF
if [ "$CONF" != "yes" ]; then
  echo "Annulation."
  exit 0
fi

# Supprimer la VM
echo "Suppression de la VM..."
az vm delete --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --yes || true

# Supprimer les disques (OS + data) si présents
if [ -n "$OS_DISK" ] && [ "$OS_DISK" != "None" ]; then
  echo "Suppression du disque OS: $OS_DISK"
  az disk delete --resource-group "$RESOURCE_GROUP" --name "$OS_DISK" --yes || true
fi

if [ -n "$DATA_DISKS" ]; then
  for d in $DATA_DISKS; do
    if [ -n "$d" ] && [ "$d" != "None" ]; then
      echo "Suppression du disque de données: $d"
      az disk delete --resource-group "$RESOURCE_GROUP" --name "$d" --yes || true
    fi
  done
fi

# Pour chaque NIC, récupérer et supprimer l'IP publique associée puis la NIC
if [ -n "$NIC_IDS" ]; then
  while read -r nic_id; do
    [ -z "$nic_id" ] && continue
    echo "Traitement NIC: $nic_id"
    PIP_ID=$(az network nic show --ids "$nic_id" --query "ipConfigurations[].publicIpAddress.id" -o tsv || true)
    if [ -n "$PIP_ID" ]; then
      echo "  Suppression IP publique: $PIP_ID"
      az network public-ip delete --ids "$PIP_ID" || true
    fi
    echo "  Suppression NIC: $nic_id"
    az network nic delete --ids "$nic_id" || true
  done <<< "$NIC_IDS"
fi

echo "Suppression terminée. Vérifiez le portail ou 'az resource list' si nécessaire."
az resource list --resource-group "$RESOURCE_GROUP" --output table || true
