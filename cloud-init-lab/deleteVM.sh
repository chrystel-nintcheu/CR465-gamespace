#!/bin/bash

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

# Supprimer la VM et ses disques
echo "Suppression de la VM et des disques associés..."
az vm delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --yes \
  --delete-os-disk \
  --delete-data-disks \
  --debug