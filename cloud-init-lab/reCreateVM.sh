#!/bin/bash
set -euo pipefail

# Fonction pour afficher le menu de sélection d'image
select_image() {
    PS3="Sélectionnez une image (1-4): "
    images=("Ubuntu2204" "Ubuntu2404" "Ubuntu2404Pro" "Debian11")
    select IMAGE in "${images[@]}"; do
        case $REPLY in
            1|2|3|4)
                echo "$IMAGE"
                break
                ;;
            *) 
                echo "Choix invalide. Veuillez sélectionner 1-4."
                ;;
        esac
    done
}

# Vérification des arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <matricule> <vm-name> [cloud-init-file]"
    echo "Exemple: $0 p123456 ubuntuDockerVM podman-cloud-init.yml"
    exit 1
fi

MATRICULE=$1
VM_NAME=$2
CLOUD_INIT_FILE=${3:-cloud-init.yml}
RESOURCE_GROUP="rg-cr465gamespace-$MATRICULE"
LOCATION="canadacentral"

# Sélection interactive de l'image
echo "Sélection de l'image système:"
IMAGE=$(select_image)

echo "Déploiement pour le matricule: $MATRICULE"
echo "Groupe de ressources: $RESOURCE_GROUP"
echo "VM: $VM_NAME"
echo "Image sélectionnée: $IMAGE"
echo "Fichier cloud-init: $CLOUD_INIT_FILE"

# Vérifier que le fichier cloud-init existe
if [ ! -f "$CLOUD_INIT_FILE" ]; then
    echo "Erreur: fichier cloud-init '$CLOUD_INIT_FILE' introuvable."
    exit 1
fi

# Supprimer la VM existante si elle existe
./deleteVM.sh "$MATRICULE" "$VM_NAME"

# Création de la nouvelle VM
echo "Création de la nouvelle VM..."
az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$IMAGE" \
    --admin-username azureuser \
    --size Standard_B1s \
    --custom-data "$CLOUD_INIT_FILE" \
    --ssh-key-values ~/.ssh/id_rsa.pub

# Ouverture des ports
echo "Configuration des règles de sécurité..."
az vm open-port --port 80 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 100
az vm open-port --port 443 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 200
az vm open-port --port 22 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --priority 300

# Récupération de l'IP publique
PUBLIC_IP=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" -d --query publicIps -o tsv)
echo "IP publique de la VM: $PUBLIC_IP"

# Suppression de l'ancienne clé SSH known_hosts si elle existe
ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "$PUBLIC_IP" 2>/dev/null || true

echo "Pour vous connecter: ssh azureuser@$PUBLIC_IP"