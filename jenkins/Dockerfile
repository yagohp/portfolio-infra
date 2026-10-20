FROM jenkins/jenkins:lts-jdk17

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV JENKINS_HOME=/var/jenkins_home

# Just to install required packages
USER root

# Docker CLI dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg git jq unzip zip make openssh-client lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg \
        | gpg --dearmor -o /usr/share/keyrings/docker.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Terraform
ARG TERRAFORM_VERSION=1.15.8
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
        -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin/ \
    && rm /tmp/terraform.zip

# Install tflint
RUN curl -sSLO https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip -d /usr/local/bin/ \
    && rm tflint_linux_amd64.zip

# Create Docker group GID 999 and add jenkins, so jenkins can run docker commands without root.
RUN groupadd -g 999 docker && usermod -aG docker jenkins

# Plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# JCasC configuration
COPY casc/ /var/jenkins_home/casc_configs/
RUN chown -R jenkins:jenkins /var/jenkins_home/casc_configs

# ─────────────────────────────────────────────────────────────
# Entrypoint customizado (garante known_hosts)
# ─────────────────────────────────────────────────────────────
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

USER jenkins

EXPOSE 8080 50000

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]