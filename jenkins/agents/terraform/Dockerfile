FROM jenkins/inbound-agent:latest

USER root

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg git jq unzip make openssh-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg \
        | gpg --dearmor -o /usr/share/keyrings/docker.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Terraform
ARG TERRAFORM_VERSION=1.15.8
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
        -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin/ \
    && rm /tmp/terraform.zip

# tflint
RUN curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip -d /usr/local/bin/ \
    && rm tflint_linux_amd64.zip

# Docker group (GID 999)
RUN groupadd -g 999 docker && usermod -aG docker jenkins

# SSH known_hosts (Host Key Git Clone)
RUN mkdir -p /home/jenkins/.ssh && \
    ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> /home/jenkins/.ssh/known_hosts 2>/dev/null && \
    chmod 700 /home/jenkins/.ssh && \
    chmod 644 /home/jenkins/.ssh/known_hosts && \
    chown -R jenkins:jenkins /home/jenkins/.ssh

USER jenkins