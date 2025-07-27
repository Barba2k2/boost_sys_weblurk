# Pipeline Shorebird - GitHub Actions

## Visão Geral

Esta pipeline automatiza o processo de criação de releases e patches do Shorebird para o projeto Boost Sys Weblurk. Ela integra com o GitHub Actions para fornecer atualizações contínuas sem intervenção manual.

## Configuração Necessária

### 1. Configurar Secret do Shorebird

No seu repositório GitHub, vá para:

1. **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**
3. Nome: `SHOREBIRD_TOKEN`
4. Valor: Seu token do Shorebird (obtenha em https://console.shorebird.dev)

### 2. Configurar Permissões do Workflow

O workflow precisa de permissões para:

- Fazer push de commits
- Criar tags
- Acessar o Shorebird

## Como Funciona

### Triggers Automáticos

1. **Push para master/main**: Cria automaticamente um patch
2. **Criação de tag (v\*)**: Cria automaticamente uma nova release
3. **Pull Request**: Executa validação (não cria patches/releases)

### Trigger Manual

Você pode executar manualmente via:

1. **Actions** → **Shorebird Pipeline** → **Run workflow**
2. Escolher ação: `release` ou `patch`
3. Opcionalmente especificar versão da release para patch

## Jobs da Pipeline

### 1. shorebird-setup

- Gera versão automática baseada na última tag
- Determina se deve criar release ou patch
- Configura variáveis de ambiente

### 2. shorebird-release

- Executa quando há nova tag ou trigger manual para release
- Cria nova release completa no Shorebird
- Atualiza versão no pubspec.yaml
- Cria tag no Git

### 3. shorebird-patch

- Executa em pushes normais para master/main
- Cria patch para a release mais recente
- Aplica automaticamente aos usuários

### 4. notify-success/notify-failure

- Notifica sucesso ou falha da operação
- Executa sempre, independente do resultado

## Fluxo de Trabalho

### Para Desenvolvimento Diário

```bash
# Faça suas alterações
git add .
git commit -m "feat: nova funcionalidade"
git push origin master

# A pipeline automaticamente:
# 1. Detecta o push
# 2. Cria um patch
# 3. Publica para os usuários
```

### Para Releases

```bash
# Crie uma tag
git tag v1.0.14
git push origin v1.0.14

# A pipeline automaticamente:
# 1. Detecta a tag
# 2. Cria nova release
# 3. Atualiza versão
# 4. Cria nova tag
```

### Para Ação Manual

1. Vá para **Actions** no GitHub
2. Selecione **Shorebird Pipeline**
3. Clique em **Run workflow**
4. Escolha ação e versão
5. Execute

## Configurações Avançadas

### Personalizar Triggers

Edite o arquivo `.github/workflows/shorebird-pipeline.yaml`:

```yaml
on:
  push:
    branches:
      - master
      - main
      - develop # Adicione outras branches
    paths:
      - "lib/**" # Só executa se mudar código
      - "pubspec.yaml"
```

## Troubleshooting

### Erro: "SHOREBIRD_TOKEN not found"

- Verifique se o secret está configurado corretamente
- Confirme o nome exato: `SHOREBIRD_TOKEN`

### Erro: "Permission denied"

- Verifique se o workflow tem permissões para push
- Configure `permissions` no workflow se necessário

### Erro: "No releases found"

- Certifique-se de que existe pelo menos uma release
- Execute manualmente uma release primeiro

### Erro: "Git authentication failed"

- Configure corretamente o token do GitHub
- Verifique se o workflow tem acesso ao repositório

## Monitoramento

### Logs da Pipeline

- Acesse **Actions** → **Shorebird Pipeline**
- Clique em qualquer execução para ver logs detalhados

### Status do Shorebird

- Console: https://console.shorebird.dev
- Verifique releases e patches criados
- Monitore downloads e aplicação de patches

### Métricas Importantes

- Taxa de sucesso das pipelines
- Tempo de execução
- Número de patches por release
- Taxa de aplicação de patches pelos usuários

## Boas Práticas

### 1. Versionamento

- Use tags semânticas (v1.0.0, v1.1.0, etc.)
- Mantenha consistência no formato

### 2. Commits

- Use Conventional Commits
- Mantenha commits pequenos e focados

### 3. Testes

- Sempre teste localmente antes do push
- Use branches de feature para mudanças grandes

### 4. Monitoramento

- Verifique logs regularmente
- Monitore métricas do Shorebird
- Responda rapidamente a falhas

## Exemplos de Uso

### Cenário 1: Correção de Bug

```bash
# Corrija o bug
git add .
git commit -m "fix: resolve problema de login"
git push origin master

# Pipeline cria patch automaticamente
# Usuários recebem correção na próxima execução
```

### Cenário 2: Nova Funcionalidade

```bash
# Desenvolva a funcionalidade
git add .
git commit -m "feat: adiciona sistema de notificações"
git push origin master

# Pipeline cria patch automaticamente
# Usuários recebem nova funcionalidade
```

### Cenário 3: Release Completa

```bash
# Prepare para release
git tag v1.1.0
git push origin v1.1.0

# Pipeline cria nova release
# Distribua novo executável
# Use patches para futuras atualizações
```

## Suporte

- [Documentação Shorebird](https://docs.shorebird.dev)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Console Shorebird](https://console.shorebird.dev)
