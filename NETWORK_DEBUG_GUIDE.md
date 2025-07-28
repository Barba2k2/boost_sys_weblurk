# Guia de Debug de Problemas de Conectividade

## Problema Identificado

O erro "Operation not permitted" (errno = 1) indica um problema de permissão de rede no macOS.

## Possíveis Causas e Soluções

### 1. Problemas de Firewall/Antivírus

- **Causa**: Firewall ou antivírus bloqueando conexões HTTPS
- **Solução**:
  - Verificar configurações do firewall
  - Adicionar exceção para o app
  - Desabilitar temporariamente para teste

### 2. Problemas de Certificado SSL

- **Causa**: Certificado SSL inválido ou expirado
- **Solução**:
  - Verificar se o certificado da API está válido
  - Testar com diferentes configurações de SSL

### 3. Problemas de DNS

- **Causa**: DNS não resolvendo corretamente
- **Solução**:
  - Usar DNS alternativo (8.8.8.8, 1.1.1.1)
  - Verificar resolução de DNS

### 4. Problemas de Proxy

- **Causa**: Proxy configurado incorretamente
- **Solução**:
  - Verificar configurações de proxy
  - Desabilitar proxy temporariamente

### 5. Problemas de Rede Corporativa

- **Causa**: Rede corporativa bloqueando conexões
- **Solução**:
  - Verificar com administrador de rede
  - Usar VPN se necessário

## Implementações Adicionadas

### 1. Logs Detalhados

- Adicionados logs detalhados no `DioRestClient`
- Logs de diagnóstico de rede no `NetworkDebug`

### 2. Teste de Conectividade

- Método `testConnectivity()` no `DioRestClient`
- Classe `NetworkDebug` para testes de rede

### 3. Retry Automático

- Implementação de retry no `DioRestClientAlternative`
- 3 tentativas com delay de 1 segundo

### 4. Timeouts Reduzidos

- Timeouts reduzidos para 30 segundos
- Configurações mais permissivas

## Como Usar

### 1. Executar Diagnóstico

```dart
await NetworkDebug.runNetworkDiagnostics();
```

### 2. Testar Conectividade

```dart
final isConnected = await dioClient.testConnectivity();
```

### 3. Usar Cliente Alternativo

Substituir `DioRestClient` por `DioRestClientAlternative` no injector.

## Próximos Passos

1. **Testar com diferentes redes**: WiFi, cabo, hotspot
2. **Verificar configurações de sistema**: Firewall, proxy, DNS
3. **Testar com VPN**: Para verificar se é problema de rede
4. **Contatar suporte da API**: Verificar se há problemas no servidor

## Comandos de Teste

### Teste de DNS

```bash
nslookup api.boostapi.com.br
```

### Teste de Conectividade

```bash
ping api.boostapi.com.br
```

### Teste de Porta

```bash
telnet api.boostapi.com.br 443
```

## Logs para Monitorar

- `=== NETWORK DIAGNOSTICS ===`
- `=== DIO ERROR DETAILS ===`
- `=== TESTING CONNECTIVITY ===`

Estes logs ajudarão a identificar exatamente onde está o problema de conectividade.
