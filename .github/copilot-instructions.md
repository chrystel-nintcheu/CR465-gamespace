# Instructions pour les Agents d'IA - CR465-gamespace

Ce référentiel contient des laboratoires pour le cours CR465, en particulier pour le déploiement d'environnements cloud avec cloud-init.

## Architecture et Structure

- `/cloud-init-lab/` : Laboratoire principal pour le déploiement de VMs Azure avec cloud-init
  - Fichiers YAML pour différentes configurations (Docker, LXD, Podman)
  - Scripts shell pour la gestion des VMs
- `/scripts/` : Scripts utilitaires pour la gestion Azure et la configuration post-déploiement

## Workflows Clés

### Déploiement d'une VM Azure

1. Utiliser les fichiers YAML dans `/cloud-init-lab/` comme templates de configuration
2. Personnaliser les fichiers selon la technologie de conteneurs souhaitée :
   - `docker-cloud-init.yml` pour Docker
   - `podman-cloud-init.yml` pour Podman
   - `lxd-cloud-init.yml` pour LXD

3. Workflow de déploiement standard :
   ```bash
   ./reCreateVM.sh <matricule> <nom-vm> <tech>-cloud-init.yml
   ```
   Exemple : `./reCreateVM.sh 12345 ubuntuDockerVM docker-cloud-init.yml`

### Gestion des Ressources Azure

- Groupe de ressources : Format standardisé `rg-cr465gamespace-<matricule>`
- Région par défaut : canadacentral
- Taille VM standard : Standard_B1s

## Conventions Importantes

1. **Nommage** :
   - VMs : Nommer selon le format `<tech>VM` (ex: ubuntuDockerVM)
   - Groupes de ressources : `rg-cr465gamespace-<matricule>`

2. **Configuration cloud-init** :
   - Mise à jour système automatique activée
   - Installation des outils de conteneurisation
   - Configuration utilisateur standard : `azureuser`

3. **Sécurité** :
   - Ports exposés par défaut : 22 (SSH), 80 (HTTP), 443 (HTTPS)
   - Authentification SSH uniquement par clé (pas de mot de passe)

## Points d'Intégration

1. **Azure CLI** :
   - Utilisé pour toutes les opérations de gestion Azure
   - Authentification requise via `az login`

2. **Cloud-Init** :
   - Point central pour la configuration automatisée des VMs
   - Logs disponibles dans `/var/log/cloud-init.log`

## Fichiers de Référence

- `/cloud-init-lab/README.md` : Documentation complète du processus de déploiement
- `/scripts/postcreate-az-vm.sh` : Script de configuration post-déploiement
- `/cloud-init-lab/reCreateVM.sh` : Script principal de déploiement

## Dépannage

1. Vérifier les logs cloud-init :
   ```bash
   sudo tail -n 200 /var/log/cloud-init.log /var/log/cloud-init-output.log
   ```

2. Vérifier le statut de cloud-init :
   ```bash
   sudo cloud-init status --long
   ```

3. Vérifier les installations :
   ```bash
   sudo tail -n 200 /var/log/apt/term.log /var/log/apt/history.log
   ```