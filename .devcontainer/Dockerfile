FROM mcr.microsoft.com/devcontainers/java:1-21-bookworm

ARG DD_JAVA_AGENT_VERSION=1.50.0

USER root

# Instala o dd-java-agent no filesystem global do container de desenvolvimento.
RUN mkdir -p /opt/datadog \
    && (curl -fsSL "https://repo1.maven.org/maven2/com/datadoghq/dd-java-agent/${DD_JAVA_AGENT_VERSION}/dd-java-agent-${DD_JAVA_AGENT_VERSION}.jar" \
      -o /opt/datadog/dd-java-agent.jar \
      || wget -qO /opt/datadog/dd-java-agent.jar "https://repo1.maven.org/maven2/com/datadoghq/dd-java-agent/${DD_JAVA_AGENT_VERSION}/dd-java-agent-${DD_JAVA_AGENT_VERSION}.jar") \
    && chmod 0644 /opt/datadog/dd-java-agent.jar

USER vscode
