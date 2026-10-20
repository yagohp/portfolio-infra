FROM jenkins/jenkins:lts-jdk17

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV JENKINS_HOME=/var/jenkins_home

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg git jq unzip zip make openssh-client lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ─── Docker CLI ───
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

# ─── SSH known_hosts para GitHub ───
RUN mkdir -p /var/jenkins_home/.ssh && \
    ssh-keyscan github.com >> /var/jenkins_home/.ssh/known_hosts && \
    chown -R jenkins:jenkins /var/jenkins_home/.ssh

# ─── Plugins ───
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# ─── JCasC ───
COPY casc/ /var/jenkins_home/casc_configs/
RUN chown -R jenkins:jenkins /var/jenkins_home/casc_configs

# ─────────────────────────────────────────────────────────────
# Entrypoint customizado (garante known_hosts)
# ─────────────────────────────────────────────────────────────
COPY scripts/entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

USER jenkins

EXPOSE 8080 50000

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]