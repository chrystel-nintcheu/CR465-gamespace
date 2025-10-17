## 1. Prepare the cloud-init YAML
Here's an example that updates the system, installs Docker and Docker Compose, adds the default user to the docker group, copies your Docker Compose file, and launches the defined services:

## 2. Preparer clés SSH 
Sur Linux, les clés SSH (y compris la clé RSA) sont généralement stockées dans le répertoire ~/.ssh/. Voici les emplacements typiques :

**Clé privée** :
```
 ~/.ssh/id_rsa
```
**Clé publique** :
```
 ~/.ssh/id_rsa.pub
```

**Pour vérifier si vous avez déjà des clés SSH, vous pouvez exécuter**

```
ls -la ~/.ssh/
```
Si vous n'avez pas encore de clé RSA, vous pouvez en générer une avec :

```
ssh-keygen -t rsa -b 4096
```

## 3. Deploy the VM with Azure CLI
### 3.1 - Choisir un abonnement par défaut
 
Voir la liste des abonnements disponible

```
az account list --output table
```
Dans le résulta affiché, assurez-vous d'utiliser l'abonnement qui correspond au tenant que vous souhaitez utiliser. Dans notre cas, on sélectionnera polymlt.

Une fois que vous avez identifié l'abonnement que vous souhaitez utiliser, vous pouvez le définir comme abonnement par défaut avec :

```
az account set --subscription "<Nom-Ou-ID-de-l-abonnement>"
```

### 3.2 - Créer un groupe de ressource.

Ici, le but est de définir un espace de travail.

Run the following from Codespaces terminal or local CLI (adjust region, VM name, etc.):

> Note: **canadacentral (Toronto)**, canadaeast (Québec)

[Product Availability by Region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/table)

[Azure Speed Test](https://www.azurespeed.com/Information/AzureRegions)

```
az group create --name rg-cr465gamespace-<votre-matricule> --location canadacentral
```

Images UbuntuLTS disponibles à ce jour pour la VM:

- **Ubuntu2204**
- **Ubuntu2404**
- Ubuntu2404Pro
- Debian11
- CentOS85Gen2 
- RHELRaw8LVMGen2
- OpenSuseLeap154Gen2 
- SuseSles15SP5
- FlatcarLinuxFreeGen2
- Win2022Datacenter
- Win2022AzureEditionCore
- Win2019Datacenter
- Win2016Datacenter
- Win2012R2Datacenter
- Win2012Datacenter

```
az vm create \
  --resource-group rg-cr465gamespace-<votre-matricule> \
  --name ubuntuDockerVM \
  --image <UbuntuLTS> \
  --admin-username azureuser \
  --size Standard_B1s \
  --custom-data cloud-init.yml \
  --ssh-key-values <path-to-your-public-key> --debug
```

## 4. Exposer les ports de votre VM

Pour HTTP (port 80)
```
az vm open-port --port 80 --resource-group rg-cr465gamespace-<votre-matricule> --name ubuntuDockerVM --priority 100
```
Pour HTTPS (port 443)
```
az vm open-port --port 443 --resource-group rg-cr465gamespace-<votre-matricule> --name ubuntuDockerVM --priority 200
```
Pour SSH (port 22)
```
az vm open-port --port 22 --resource-group rg-cr465gamespace-<votre-matricule> --name ubuntuDockerVM --priority 300
```
## 5. Ouvrir une connexion SSh

After deployment, get the VM's public IP:

```
az vm show --resource-group rg-cr465gamespace-<votre-matricule> --name ubuntuDockerVM -d --query publicIps -o tsv
```
The connect :


```
ssh azureuser@<public-ip>

```
### 5.1 - Vérifier l'installation de la VM

Une fois dans la VM:

```
sudo cloud-init status --long
sudo tail -n 200 /var/log/cloud-init.log /var/log/cloud-init-output.log
sudo tail -n 200 /var/log/apt/term.log /var/log/apt/history.log
```

## 6. Afin d'écraser votre VM puis rédéployer sans repasser au travers de toutes les étapes ci-dessus:

```
./reCreateVM.sh <votre-matricule> <VM-NAME>
```

Et puis pour mettre fin à l'expérimentation et donc détruire la VM

```
./deleteVM.sh <votre-matricule> <VM-NAME>
```