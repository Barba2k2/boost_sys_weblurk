# Solução para Problemas de Rede no macOS

## Problema Identificado

O erro `Operation not permitted` (errno = 1) no macOS indica que o app não tem permissão para fazer conexões de rede.

## Soluções Implementadas

### 1. Permissões de Rede no Info.plist

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.boostapi.com.br</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <false/>
        </dict>
    </dict>
</dict>
```

### 2. Entitlements para macOS

**DebugProfile.entitlements:**

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

**Release.entitlements:**

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

### 3. Configurações Específicas no DioRestClient

- HttpClient personalizado para macOS
- Configurações de certificado mais permissivas
- Teste de conectividade usando HttpClient direto

## Próximos Passos

### 1. Recompilar o App

```bash
flutter clean
flutter pub get
flutter build macos
```

### 2. Verificar Permissões do Sistema

1. Abrir **Preferências do Sistema** > **Segurança e Privacidade**
2. Ir para aba **Firewall**
3. Verificar se o app está permitido
4. Se não estiver, clicar em **Permitir conexões de entrada**

### 3. Verificar Configurações de Rede

1. **Preferências do Sistema** > **Rede**
2. Verificar se a conexão está ativa
3. Testar conectividade com outros apps

### 4. Testar com Diferentes Redes

- WiFi doméstico
- Hotspot do celular
- Rede corporativa (pode ter firewall)

### 5. Verificar Certificados SSL

```bash
openssl s_client -connect api.boostapi.com.br:443
```

## Comandos de Debug

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

### Verificar Logs do Sistema

```bash
sudo log show --predicate 'process == "boost_sys_weblurk"' --last 1h
```

## Soluções Alternativas

### 1. Desabilitar App Sandbox Temporariamente

No `DebugProfile.entitlements`:

```xml
<key>com.apple.security.app-sandbox</key>
<false/>
```

### 2. Usar Proxy Local

```bash
# Instalar mitmproxy
brew install mitmproxy

# Executar proxy
mitmproxy -p 8080
```

### 3. Configurar DNS Alternativo

```bash
# Usar DNS do Google
networksetup -setdnsservers "Wi-Fi" 8.8.8.8 8.8.4.4
```

## Logs para Monitorar

- `=== TESTING CONNECTIVITY ===`
- `Direct HttpClient test successful/failed`
- `Bad certificate for host:port`

## Contato com Suporte

Se o problema persistir:

1. Coletar logs do sistema
2. Verificar versão do macOS
3. Testar em outro Mac
4. Contatar suporte da API

## Notas Importantes

- O app precisa ser recompilado após mudanças nos entitlements
- Permissões de rede podem ser bloqueadas por antivírus
- Firewalls corporativos podem bloquear conexões HTTPS
- Certificados SSL podem estar expirados ou inválidos
