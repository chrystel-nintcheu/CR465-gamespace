# Conteneur LXD & interopérabilité avec docker
Ce tutoriel démontre l'interopérabilité entre les technologies docker et lxd. 
Cette configuration permet l'exécution d'image dokcer.io/ngnix, de l’exposer sur le port 80 à l’intérieur du conteneur LXD, puis de rendre ce port accessible extérieurement via une règle proxy LXD. 

### Prérequis:

- Une machine Ubuntu 24.04 LTS à jour.​
- LXD installé (snap install lxd ou via apt ou via cloud-init).
- Droits administrateur (sudo).
- Connexion Internet active.
                        # LXD & interopérabilité avec Docker

                        Ce tutoriel montre comment utiliser LXD pour exécuter une instance Docker (par exemple Nginx) à l'intérieur d'un conteneur LXD, puis exposer le port 80 du conteneur vers l'hôte via un device proxy LXD.

                        ## Table des matières

                        - [Pré-requis](#pré-requis)
                        - [1. Installation et initialisation de LXD](#1-installation-et-initialisation-de-lxd)
                        - [2. Créer un conteneur système](#2-créer-un-conteneur-système)
                        - [3. Configurer le conteneur pour exécuter Docker](#3-configurer-le-conteneur-pour-exécuter-docker)
                        - [4. Installer Docker dans le conteneur](#4-installer-docker-dans-le-conteneur)
                        - [5. Déployer une application (Nginx)](#5-déployer-une-application-nginx)
                        - [6. Exposer le port du conteneur sur l'hôte](#6-exposer-le-port-du-conteneur-sur-lhôte)
                        - [Dépannage et remarques](#dépannage-et-remarques)
                        - [Références](#références)

                        ## Pré-requis

                        - Une machine Ubuntu 24.04 LTS (ou similaire) à jour
                        - LXD installé (via snap, apt, ou cloud-init)
                        - Droits administrateur (sudo)
                        - Connexion Internet

                        Remarque : un fichier de configuration cloud-init est fourni dans `../cloud-init-lab/lxd-cloud-init.yml` si vous souhaitez automatiser l'installation.

                        ## 1. Installation et initialisation de LXD

                        Se référer à la documentation officielle : https://linuxcontainers.org/lxd/installation/ ou utilisez le fichier `cloud-init-lab/lxd-cloud-init.yml`.

                        Initialiser LXD :

## 1. Installation et initialisation

Se référer au répertoire et fichier cloud-init-lab/lxd-cloud-init.yml ou l'installer vous même au travers de la [documentation officielle](https://canonical.com/lxd/install)
                 
### 1.1. Initialiser LXD

```
sudo lxd init
```
                 Accepter les valeurs par défaut ou répondre en fonction de vos besoins. Résultat attendu: 

                 ```
                 config: {}
                 networks:
                 - config:
                     ipv4.address: auto


                        ```bash
                        sudo lxd init
                        ```

                        Acceptez les valeurs par défaut ou répondez selon vos besoins. Exemple de sortie attendue (extrait) :

                        ```text
                        config: {}
                        networks:
                        - config:
                            ipv4.address: auto
                            ipv6.address: none
                            name: lxdbr0
                        storage_pools:
                        - name: default
                          driver: dir
                        profiles:
                        - name: default
                          devices:
                            eth0:
                              name: eth0
                              network: lxdbr0
                              type: nic
                        ```

                        ## 2. Créer un conteneur système

                        Créer un conteneur Ubuntu (exemple `CN1`) :

                        ```bash
                        lxc launch ubuntu:24.04 CN1
                        ```

                        ## 3. Configurer le conteneur pour exécuter Docker

                        Docker peut nécessiter des privilèges supplémentaires. Activez le nesting et les interceptions système requises :

                        ```bash
                        lxc config set CN1 security.nesting=true
                        lxc config set CN1 security.syscalls.intercept.mknod=true
                        lxc config set CN1 security.syscalls.intercept.setxattr=true
                        # Redémarrer le conteneur après modification
                        lxc restart CN1
                        ```

                        Conseil : si vous rencontrez des erreurs liées aux permissions (ex. `pivot_root .: permission denied`) sur Ubuntu 24.04, envisagez d'exécuter Docker dans une VM LXD plutôt que dans un conteneur LXD (moins de restrictions). Exemple de création d'une VM LXD :

                        ```bash
                        lxc launch images:ubuntu/24.04/cloud --vm VM1
                        ```

                        ## 4. Installer Docker dans le conteneur

                        Accéder au conteneur :

                        ```bash
                        lxc exec CN1 -- bash
                        ```

                        Installer Docker et docker-compose :

                        ```bash
                        apt update && apt upgrade -y
                        apt install -y docker.io docker-compose
                        ```

                        Tester Docker :

                        ```bash
                        docker run --rm hello-world
                        ```

                        Si l'exécution échoue à cause des cgroups/noyau, utilisez une VM LXD (voir section précédente).

                        ## 5. Déployer une application (Nginx)

                        Dans le conteneur LXD (ou VM LXD), lancez Nginx via Docker :

                        ```bash
                        docker run -d --name nginx-server -p 80:80 nginx
                        ```

                        Vérifier les conteneurs et les adresses IP :

                        ```bash
                        lxc ls
                        ```

                        Exemple de sortie (extrait):

                        ```text
                        +------+---------+-----------------------+------+-----------+-----------+
                        | NAME |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
                        +------+---------+-----------------------+------+-----------+-----------+
                        | CN1  | RUNNING | 172.17.0.1 (docker0)  |      | CONTAINER | 0         |
                        |      |         | 10.243.141.244 (eth0) |      |           |           |
                        +------+---------+-----------------------+------+-----------+-----------+
                        ```

                        ## 6. Exposer le port du conteneur sur l'hôte

                        Sur l'hôte LXD, créez un device proxy qui redirige le port 80 de l'hôte vers le conteneur :

                        ```bash
                        lxc config device add CN1 myport80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
                        ```

                        Vérifier la configuration des devices :

                        ```bash
                        lxc config device show CN1
                        ```

                        Tester l'accès externe depuis un navigateur : http://<IP_de_votre_hôte>

                        Retirer la redirection :

                        ```bash
                        lxc config device remove CN1 myport80
                        ```

                        ## Dépannage et remarques

                        - Erreurs Docker liées à `pivot_root` ou aux cgroups sur Ubuntu 24.04 : privilégier une VM LXD.
                        - Sur ZFS, le stockage Docker a connu des problèmes historiques ; vérifier la compatibilité du noyau si nécessaire.
                        - Pour les installations automatisées, utilisez `cloud-init-lab/lxd-cloud-init.yml`.

                        ## Références

                        - Documentation LXD : https://linuxcontainers.org/
                        - Exemples cloud-init : `cloud-init-lab/`
