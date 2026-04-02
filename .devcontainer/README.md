# Dev Container Java 21 + Datadog + Fluent Bit

## Objetivo
Este dev container foi desenhado para desenvolvimento Java com observabilidade local no padrao sidecar:

- `app`: container principal onde o VS Code conecta
- `datadog-agent`: receptor de traces e metricas (DogStatsD)
- `fluent-bit`: coletor e encaminhador de logs para Datadog

Requisitos de design atendidos:

- Sem log em arquivo da aplicacao
- Coleta de logs via `stdout/stderr` do container
- `dd-java-agent` aplicado por padrao em qualquer JVM no `app`
- Reutilizavel entre projetos Java

## Arquitetura
Fluxo de telemetria:

1. Traces: JVM (`dd-java-agent`) -> `datadog-agent:8126`
2. Metricas: JVM/Micrometer/DogStatsD -> `datadog-agent:8125/udp`
3. Logs: `stdout/stderr` do container `app` -> driver `fluentd` do Docker -> `fluent-bit:24224` -> Datadog Logs Intake

Componentes chave:

- `JAVA_TOOL_OPTIONS` global no `app` injeta automaticamente:
  - `-javaagent:/opt/datadog/dd-java-agent.jar`
  - `dd.service`, `dd.env`, `dd.version`
  - `dd.logs.injection=true`
  - `dd.trace.agent.url=http://datadog-agent:8126`
  - `dd.dogstatsd.host=datadog-agent`, `dd.dogstatsd.port=8125`
- `fluent-bit` recebe logs via `forward input` (porta 24224) e envia para Datadog.

## Estrutura de arquivos
```text
.devcontainer/
  .env.example
  certs/
    .gitkeep
  devcontainer.json
  Dockerfile
  docker-compose.yml
  fluent-bit/
    fluent-bit.conf
  scripts/
    import-jvm-certs.sh
    shell-log-bridge.sh
  dd-java-agent.jar
```

## Configuracao inicial
1. Copie `.devcontainer/.env.example` para `.devcontainer/.env`.
2. Preencha os valores:
   - `DD_API_KEY`
   - `DD_SITE` (ex: `datadoghq.com`, `us5.datadoghq.com`)
   - `DD_SERVICE` (nome do servico no Datadog)
   - `DD_ENV` (ex: `dev`)
   - `DD_VERSION` (ex: `1.0`)
3. No VS Code, use `Dev Containers: Reopen in Container`.

## Nome do servico no Datadog
O nome usado em traces/logs/metricas vem de `DD_SERVICE`.

- Arquivo: `.devcontainer/.env`
- Exemplo: `DD_SERVICE=app-dev-container`

Se quiser mudar o nome visivel no Datadog, altere somente essa variavel e recrie os containers:

```bash
docker compose -f .devcontainer/docker-compose.yml up -d --force-recreate
```

## Certificado corporativo na JVM
Este setup suporta dois modos:

### Modo 1 (recomendado): truststore completa
Coloque seu arquivo corporativo em:

```text
.devcontainer/certs/cacerts
```

No build, ele substitui a truststore padrao da JVM.

### Modo 2: certificados individuais
Coloque `.crt`, `.cer` ou `.pem` em:

```text
.devcontainer/certs/
```

No build, os certificados sao importados no `cacerts` com alias `corp-*`.

### Aplicar alteracoes de certificado
Sempre que mudar algo em `.devcontainer/certs`, rode:

```bash
Dev Containers: Rebuild Container
```

## Como rodar a aplicacao
Dentro do container `app`:

```bash
./mvnw spring-boot:run
```

Ou:

```bash
java -jar target/*.jar
```

As portas publicadas do `app` no host sao:

- `8080` (HTTP app)
- `5005` (debug JVM)

## Play da IDE vs terminal
Para logs, o caminho mais confiavel e rodar no terminal do container.

Motivo:
- o play da IDE pode executar por canal proprio do debugger/IDE
- nesse caso, parte do output pode nao cair no fluxo de log capturado pelo Docker + Fluent Bit

Se quiser usar play da IDE, configure para executar em terminal integrado ou use wrapper shell que escreve tambem em `/proc/1/fd/1`.

## Validacoes rapidas
### App viva
```bash
curl -i http://localhost:8080/actuator/health
curl -i http://localhost:8080/testando
```

### Agent carregado na JVM
```bash
java -version
```
Saida esperada inclui `Picked up JAVA_TOOL_OPTIONS: -javaagent:/opt/datadog/dd-java-agent.jar`.

### Traces no Datadog Agent
```bash
docker exec datadog-agent agent status
```
Verifique secao `APM Agent` e `Receiver (previous minute)`.

### Metricas DogStatsD
```bash
docker exec datadog-agent agent status
```
Verifique secao `DogStatsD` (`Metric Packets` subindo).

### Logs no Fluent Bit
```bash
docker compose -f .devcontainer/docker-compose.yml exec app bash -lc "curl -s http://fluent-bit:2020/api/v1/metrics"
```
Verifique `input.forward.0.records` e `output.datadog.0.proc_records`.

## Troubleshooting
### 1) Logs nao aparecem no Datadog
- confira `DD_API_KEY` e `DD_SITE` em `.devcontainer/.env`
- confirme que `fluent-bit` esta sem erro de output:
  - `docker logs fluent-bit`
- confirme que os contadores do Fluent Bit estao subindo:
  - `curl http://fluent-bit:2020/api/v1/metrics`
- abra Logs Explorer com filtro:
  - `service:<DD_SERVICE> env:<DD_ENV> source:java`

### 2) Endpoint localhost:8080 nao responde
- confirme app rodando:
  - `docker compose -f .devcontainer/docker-compose.yml exec app ss -lntp | grep :8080`
- se nao estiver rodando, suba a app novamente:
  - `docker compose -f .devcontainer/docker-compose.yml exec app bash -lc "cd /workspace && ./mvnw spring-boot:run"`

### 3) Porta parece aberta sem app
- `8126` e `24224` ficam abertas por sidecars (`datadog-agent`, `fluent-bit`)
- para desligar tudo:
  - `docker compose -f .devcontainer/docker-compose.yml down`

### 4) Alterei env e nao refletiu
- rode `up` com recreate:
  - `docker compose -f .devcontainer/docker-compose.yml up -d --force-recreate`

## Comandos uteis
```bash
docker compose -f .devcontainer/docker-compose.yml up -d
docker compose -f .devcontainer/docker-compose.yml down
docker compose -f .devcontainer/docker-compose.yml ps
docker compose -f .devcontainer/docker-compose.yml logs -f app
docker logs -f fluent-bit
docker logs -f datadog-agent
```

