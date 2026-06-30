FROM jenkins/jenkins:lts-jdk17

USER root

ARG DOCKER_GID=1001

RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Permite o usuário jenkins usar o Docker do host
RUN groupadd -f -g ${DOCKER_GID} docker \
    && usermod -aG docker jenkins

# SonarScanner instalado na imagem (evita docker run na etapa SonarQube)
RUN curl -sSLo /tmp/sonar-scanner.zip \
      https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.2.1.4610-linux-x64.zip \
    && unzip -q /tmp/sonar-scanner.zip -d /opt \
    && ln -sf /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/sonar-scanner \
    && rm /tmp/sonar-scanner.zip

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY casc_configs/ /usr/share/jenkins/ref/casc_configs/

USER jenkins
