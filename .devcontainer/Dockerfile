FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update --fix-missing \
    && apt list --upgradable \
    && apt-get install -y unzip xz-utils\
    # Installer les dépendances nécessaires pour Docker
    && apt-get install -y ca-certificates curl gnupg lsb-release \
    # Installer Azure CLI et Bicep
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && az bicep install \
    # Installer Bicep CLI directement (optionnel, pour s'assurer que bicep est disponible en ligne de commande)
    && curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
    && chmod +x ./bicep \
    && mv ./bicep /usr/local/bin/bicep \
    # Ajouter la clé GPG officielle de Docker
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    # Ajouter le dépôt Docker
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    # Installer Docker Engine
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    # Installer Docker Compose
    && curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    # Nettoyage
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    