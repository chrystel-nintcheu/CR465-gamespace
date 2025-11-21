# Conteneur et infonuagique

> Déployer une image drupal avec bicep dans azure

## Deploy
```
az deployment group create \
  --resource-group yourResourceGroup  \
  --template-file main.bicep \
  --parameters @params.json --debug
```

Exemple: 

```
az deployment group create \
  --resource-group rg-cr465gamespace-p109903 \
  --template-file main.bicep \
  --parameters main.parameters.json --debug
```


## Get IP
```
az container show \
  --resource-group yourResourceGroup \
  --name drupal-dev \
  --query "{IP:ipAddress.ip}" \
  --output tsv
```

Exemple:

```
az container show \
  --resource-group rg-cr465gamespace-p109903 \
  --name drupal-dev \
  --query "{IP:ipAddress.ip}" \
  --output tsv
```

## Destroy

```
az deployment group create \
  --resource-group yourResourceGroup  \
  --template-file destroy-main.bicep \
  --parameters @params.json --mode Complete --debug
```

Exemple: 

```
az deployment group create \
  --resource-group rg-cr465gamespace-p109903 \
  --template-file destroy-main.bicep \
   --mode Complete --debug
```
