# Séance 11 - Introduction à l'infrastructure comme code (Cas de Bicep)

## 1. Fichier de paramètres (main.parameters.json)

```json
{
  "adminUsername": {
    "value": "azureuser"
  },
  "sshPublicKey": {
    "value": "COLLEZ_VOTRE_CLÉ_PUBLIQUE_ICI"
  },
  "instanceCount": {
    "value": 2
  },
  "vmSku": {
    "value": "Standard_B1s"
  },
  "imageReference": {
    "value": {
      "publisher": "Canonical",
      "offer": "0001-com-ubuntu-server-jammy",
      "sku": "22_04-lts-gen2",
      "version": "latest"
    }
  }
}
```

## 2. Commandes de déploiement et test

2.1. **Simulation what-if avant déploiement réel :**

```sh
az deployment group what-if \
  --resource-group MonGroupe \
  --template-file main.bicep \
  --parameters @main.parameters.json --debug
```

2.1. **Déploiement complet :**

```sh
az deployment group create \
  --resource-group MonGroupe \
  --template-file main.bicep \
  --parameters @main.parameters.json --debug
```

2.2. **Récupérer les IPs publiques (à la fin du déploiement) :**

```sh
az vmss list-instance-public-ips --resource-group MonGroupe --name mon-vmss
```

2.3. **Connexion SSH :**

```sh
ssh -i ~/.ssh/id_rsa azureuser@ADRESSE_IP
```

2.4 **Vérification Docker :**

```sh
docker --version
```

# Destroy

```
az deployment group create --resource-group MonGroupe --name mon-vmss --template-file destroy-main.bicep --mode Complete --debug
```

az deployment group create --resource-group rg-cr465gamespace-p109903 --name mon-vmss --template-file destroy-main.bicep --mode Complete --debug