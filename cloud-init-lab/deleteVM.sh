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
VM_NAME="ubuntuDockerVM"
LOCATION="canadacentral"

echo "Déploiement pour le matricule: $MATRICULE"
echo "Groupe de ressources: $RESOURCE_GROUP"

# Suppression de la VM existante si elle existe
echo "Suppression de la VM existante..."
az vm delete \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --yes
