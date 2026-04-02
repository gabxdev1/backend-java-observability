FROM mcr.microsoft.com/devcontainers/java:1-21-bookworm

USER root

COPY .devcontainer/dd-java-agent.jar /opt/datadog/dd-java-agent.jar
COPY .devcontainer/scripts/shell-log-bridge.sh /usr/local/share/devcontainer/shell-log-bridge.sh

# Configura permissões e ativa bridge de logs no shell interativo.
RUN chmod 0644 /opt/datadog/dd-java-agent.jar \
    && chmod 0644 /usr/local/share/devcontainer/shell-log-bridge.sh \
    && echo "source /usr/local/share/devcontainer/shell-log-bridge.sh" >> /etc/bash.bashrc

USER vscode
