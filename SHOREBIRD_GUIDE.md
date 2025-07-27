# Guia Shorebird - Boost Sys Weblurk

## O que é Shorebird?

O Shorebird é uma ferramenta de code push para Flutter que permite atualizar aplicativos sem precisar fazer um novo build completo. Ele funciona criando patches que são aplicados em tempo de execução.

## Configuração Atual

O projeto já está configurado com Shorebird para Windows:

- **App ID**: `71063563-6661-419b-8042-20ab86434cd5`
- **Versão atual**: `1.0.14+1`
- **Plataforma**: Windows
- **Status**: ✅ Configurado e funcionando

## Arquivos de Configuração

### shorebird.yaml

```yaml
app_id: 71063563-6661-419b-8042-20ab86434cd5
# auto_update: false  # Descomente para desabilitar atualizações automáticas
```

### pubspec.yaml

O arquivo já inclui:

```yaml
dependencies:
  shorebird_code_push: ^2.0.4

flutter:
  assets:
    - shorebird.yaml
```

## Comandos Principais

### 1. Verificar Status

```bash
shorebird doctor
```

### 2. Criar uma Nova Release

```bash
shorebird release windows
```

- Cria uma nova versão completa do app
- Use quando houver mudanças significativas (novas dependências, mudanças nativas, etc.)

### 3. Criar um Patch

```bash
shorebird patch windows --release-version=1.0.14+1
```

- Cria um patch para a versão especificada
- Use para correções de bugs e melhorias menores
- O patch será aplicado automaticamente quando o usuário abrir o app

### 4. Verificar Releases

```bash
shorebird releases get-apks --release-version=1.0.14+1
```

## Fluxo de Trabalho

### Para Correções Menores (Patches)

1. Faça suas alterações no código
2. Execute: `shorebird patch windows --release-version=1.0.14+1`
3. O patch será publicado automaticamente
4. Os usuários receberão a atualização na próxima vez que abrirem o app

### Para Mudanças Significativas (Releases)

1. Atualize a versão no `pubspec.yaml`
2. Execute: `shorebird release windows`
3. Distribua o novo executável
4. Use patches para futuras atualizações menores

## Como Funciona no App

O `UpdateService` (lib/core/services/update_service.dart) gerencia as atualizações:

- Verifica automaticamente por atualizações quando o app inicia
- Verifica novamente quando o app volta do background
- Mostra um diálogo quando uma atualização está disponível
- Aplica a atualização e reinicia o app automaticamente

## Limitações

### O que PODE ser atualizado via patch:

- Código Dart puro
- Assets (imagens, fontes, etc.)
- Lógica de negócio
- UI/UX

### O que NÃO pode ser atualizado via patch:

- Dependências nativas
- Plugins nativos
- Configurações do AndroidManifest.xml
- Permissões
- Mudanças no pubspec.yaml que afetem dependências

## Troubleshooting

### Erro de permissão no build

```bash
# Execute como administrador ou verifique permissões da pasta
```

### Erro de long paths no Git

```bash
git config --global core.longpaths true
```

### Verificar logs

Os logs do Shorebird estão em: `C:\Users\[usuario]\AppData\Roaming\shorebird\logs\`

## Exemplo de Uso

### Cenário 1: Correção de Bug

1. Corrija o bug no código
2. `shorebird patch windows --release-version=1.0.14+1`
3. ✅ Usuários recebem a correção automaticamente

### Cenário 2: Nova Funcionalidade

1. Adicione a nova funcionalidade
2. `shorebird patch windows --release-version=1.0.14+1`
3. ✅ Usuários recebem a nova funcionalidade automaticamente

### Cenário 3: Nova Dependência

1. Adicione a nova dependência no pubspec.yaml
2. `flutter pub get`
3. `shorebird release windows` (nova release completa)
4. Distribua o novo executável

## Monitoramento

- Use o console do Shorebird para monitorar downloads de patches
- Verifique logs para identificar problemas
- Monitore a taxa de sucesso das atualizações

## Boas Práticas

1. **Sempre teste patches** antes de publicar
2. **Use releases** para mudanças significativas
3. **Mantenha patches pequenos** para melhor performance
4. **Monitore logs** para identificar problemas
5. **Comunique mudanças** importantes aos usuários

## Suporte

- [Documentação oficial](https://docs.shorebird.dev)
- [Console Shorebird](https://console.shorebird.dev)
- [GitHub Shorebird](https://github.com/shorebirdtech/shorebird)
