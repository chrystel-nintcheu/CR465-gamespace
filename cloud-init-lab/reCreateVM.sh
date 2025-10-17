#!/bin/bash

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <matricule>"
    echo "Exemple: $0 123456"
    exit 1
fi

# Définition des variables
MATRICULE=$1
RESOURCE_GROUP="rg-cr465gamespace-$MATRICULE"
VM_NAME="ubuntuVM"
LOCATION="canadacentral"

echo "Déploiement pour le matricule: $MATRICULE"
echo "Groupe de ressources: $RESOURCE_GROUP"

# Suppression de la VM existante si elle existe
./deleteVM.sh $MATRICULE

# Création de la nouvelle VM
echo "Création de la nouvelle VM..."
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image Ubuntu2404 \
    --admin-username azureuser \
    --size Standard_B1s \
    --custom-data cloud-init.yml \
    --ssh-key-values ~/.ssh/id_rsa.pub

# Ouverture des ports
echo "Configuration des règles de sécurité..."
az vm open-port --port 80 --resource-group $RESOURCE_GROUP --name $VM_NAME --priority 100
az vm open-port --port 443 --resource-group $RESOURCE_GROUP --name $VM_NAME --priority 200
az vm open-port --port 22 --resource-group $RESOURCE_GROUP --name $VM_NAME --priority 300

# Récupération de l'IP publique
echo "Récupération de l'IP publique..."
PUBLIC_IP=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME -d --query publicIps -o tsv)
echo "IP publique de la VM: $PUBLIC_IP"

# remove without prompt the old key if it exists
ssh-keygen -f '/home/vscode/.ssh/known_hosts' -R $PUBLIC_IP

echo "Pour vous connecter: ssh azureuser@$PUBLIC_IP"