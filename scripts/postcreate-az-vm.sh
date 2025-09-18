#!/bin/bash
set -e
apt-get update --fix-missing \
    && apt list --upgradable \
    && apt-get install -y unzip xz-utils git-lfs\
    && git lfs install \
    && apt-get install -y ca-certificates curl gnupg lsb-release \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && az bicep install \
    && curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
    && chmod +x ./bicep \
    && mv ./bicep /usr/local/bin/bicep \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update --fix-missing \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && systemctl enable docker \
    && systemctl start docker \
    && usermod -aG docker $USER \
    && newgrp docker \
    && systemctl status docker --no-pager \
    && docker run --rm -d --name nginxCT -p 80:80 nginx:latest \
    && docker ps -a \
