FROM mcr.microsoft.com/devcontainers/java:1-21-bookworm

USER root

COPY .devcontainer/dd-java-agent.jar /opt/datadog/dd-java-agent.jar
COPY .devcontainer/scripts/shell-log-bridge.sh /usr/local/share/devcontainer/shell-log-bridge.sh
COPY .devcontainer/scripts/import-jvm-certs.sh /usr/local/share/devcontainer/import-jvm-certs.sh
COPY .devcontainer/certs/ /tmp/corp-certs/

# Configura permissões, importa certificados corporativos e ativa bridge de logs.
RUN chmod 0644 /opt/datadog/dd-java-agent.jar \
    && chmod 0644 /usr/local/share/devcontainer/shell-log-bridge.sh \
    && chmod 0755 /usr/local/share/devcontainer/import-jvm-certs.sh \
    && /usr/local/share/devcontainer/import-jvm-certs.sh /tmp/corp-certs \
    && echo "source /usr/local/share/devcontainer/shell-log-bridge.sh" >> /etc/bash.bashrc

USER vscode
