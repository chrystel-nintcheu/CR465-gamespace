#!/bin/bash
set -euo pipefail

# Appel des recommandations Azure (best practices)
get_bestpractices --resource general --action deployment || true

# Vérification des arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <matricule> <vm-name> [cloud-init-file]"
    echo "Exemple: $0 p123456 ubuntuDockerVM cloud-init-docker.yml"
    exit 1
fi

MATRICULE=$1
VM_NAME=$2
CLOUD_INIT_FILE=${3:-cloud-init.yml}

RESOURCE_GROUP="rg-cr465gamespace-$MATRICULE"
LOCATION="canadacentral"

echo "Déploiement pour le matricule: $MATRICULE"
echo "Groupe de ressources: $RESOURCE_GROUP"
echo "VM: $VM_NAME"
echo "Fichier cloud-init: $CLOUD_INIT_FILE"

# Vérifier que le fichier cloud-init existe
if [ ! -f "$CLOUD_INIT_FILE" ]; then
  echo "Erreur: cloud-init file '$CLOUD_INIT_FILE' introuvable."
  exit 1
fi

# Supprimer la VM existante si elle existe (transmettre le nom)
#./deleteVM.sh "$MATRICULE" "$VM_NAME"

# Création de la nouvelle VM
echo "Création de la nouvelle VM..."
az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image Ubuntu2404 \
    --admin-username azureuser \
    --size Standard_B1s \
    --custom-data "$CLOUD_INIT_FILE" \
    --ssh-key-values ~/.ssh/id_rsa.pub

# Ouverture des ports (unique priorité par règle)
echo "Configuration des règles de sécurité..."
az vm open-port --port 80 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 100
az vm open-port --port 443 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 200
az vm open-port --port 22 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 300

# Récupération de l'IP publique
echo "Récupération de l'IP publique..."
PUBLIC_IP=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" -d --query publicIps -o tsv)
echo "IP publique de la VM: $PUBLIC_IP"

# remove without prompt the old key if it exists
ssh-keygen -f '/home/vscode/.ssh/known_hosts' -R "$PUBLIC_IP" || true

echo "Pour vous connecter: ssh azureuser@$PUBLIC_IP"