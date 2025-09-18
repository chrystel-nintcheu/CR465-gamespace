
````
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

La paire de clés SSH a été générée avec succès :

Clé privée : ~/.ssh/id_rsa
Clé publique : ~/.ssh/id_rsa.pub

Vous pouvez utiliser la clé publique pour l’ajouter à un serveur ou à GitHub, et la clé privée pour vous authentifier depuis votre Codespace.


Pour définir un groupe de ressources par défaut avec Azure CLI, il faut utiliser la commande suivante :

```
az configure --defaults group=<nom-du-resource-group>
```
Pour lister les groupes de ressources disponibles avec Azure CLI, utilisez :

```
az group list --output table
```

Pour supprimer un groupe de ressources avec Azure CLI, utilisez :
```
az group delete --name <nom-du-resource-group> --yes --no-wait
```