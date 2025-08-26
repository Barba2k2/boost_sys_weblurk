Agente Flutter (Windows Desktop) — Diagnóstico e Correção do Login (MVVM)
Contexto
App Flutter desktop Windows, arquitetura MVVM.

Em produção, via Postman, o login funciona normalmente.

No app desktop, alguns usuários não conseguem logar.

Usuários de teste (produção):

GriingoBRasileiro / senha: boost123
bruce_wayne_rp / senha: boost123
Headshot_BR / senha: boost123
Objetivo: reproduzir, identificar a causa raiz, corrigir e entregar relatório.

Escopo da Tarefa
Reprodução controlada

Executar o app em Windows (modo release e debug).
Validar se o botão “Entrar” habilita com os três usuários acima.
Tentar login e capturar toda a telemetria de rede (ver abaixo).
Paridade Postman × App

Garanta que o app está apontando para o mesmo baseUrl e endpoint do Postman (produção).

Compare método, path, query, headers e body:

Método (geralmente POST).
Headers obrigatórios: Content-Type: application/json, Accept: application/json, Authorization (se houver), User-Agent (se relevante para WAF/CDN).
Corpo: chaves exatamente iguais às aceitas pela API (ex.: username vs email, password, grant_type, etc.).
Formatação: JSON puro vs x-www-form-urlencoded/FormData.
Trailing slash no baseUrl e no path.
Gere um cURL a partir do app (log estruturado) e compare com o cURL do Postman (paridade 1:1).

Auditoria do fluxo MVVM

Inspecione LoginView, LoginViewModel, LoginUseCase, AuthRepository, RemoteAuthDataSource (ou equivalentes).

Procure por transformações indevidas:

username.toLowerCase(), trim(), remoção de _/caracteres especiais, normalização de acentos.
Mapeamento de campos (ex.: enviar email quando deveria ser username).
Verifique validações de form/inputFormatters que possam bloquear underscore (_) ou case.

Confirme await/encadeamento correto e tratamento de exceções (DioError, SocketException, HandshakeException, HttpException).

Camada de rede (Dio/Http)

Ativar Logging Interceptor temporário (sem vazar senha; ofusque o campo).

Checar:

baseUrl efetivo (logar).
followRedirects, validateStatus, responseType.
timeou​​ts e possíveis retry/policies.
Certificado/TLS no Windows: erros como CERTIFICATE_VERIFY_FAILED/HandshakeException.
Presença de WAF/CDN (ex.: Cloudflare) retornando HTML/403; comparar User-Agent.
Confirmar Content-Type coerente com a API.

Config e ambientes

Verifique flavors / .env / dart-define carregados no Windows:

Se o app está usando produção real (sem confundir com staging).
Diferenças de baseUrl por plataforma (mobile x desktop).
Logar (temporariamente) o baseUrl carregado na inicialização.

Armazenamento local e estado

Limpar shared_preferences/cache/token antes de novos testes (para descartar token inválido).
Verificar se há hashing local da senha (ex.: MD5/SHA) quando a API espera texto puro.
Conferir serialização de JSON (encoding/charset) e locale no Windows.
Testes automatizados mínimos

Criar teste de integração que chama o AuthRepository.login() com os três usuários em ambiente de produção “simulado” (usando o mesmo baseUrl do app) e valida 200 + payload esperado.
Adicionar teste unitário para garantir que nenhuma transformação indevida é aplicada ao username (case e _ preservados).
Correção

Ajustar o que for necessário na camada correta (ViewModel/Repository/DataSource/Config).
Manter logs mínimos (apenas de erro) pós‐correção.
Não alterar regras de negócio da API; focar no pipeline de login do cliente.
Entrega

PR dedicado: título “Fix: Desktop Login parity with Prod API”.
Descrição com causa raiz, mudanças e como testar (passo a passo).
Relatório final (ver modelo abaixo).
Diff destacado dos arquivos alterados e antes/depois das requisições (headers + body, sem senha).
Aceite (Definition of Done)
Os três usuários conseguem logar no app desktop Windows em produção.
Requisições do app são idênticas (semântica e sintaxe) às do Postman que funcionam.
Sem regressões no mobile (se aplicável).
Logs reduzidos a apenas erros críticos.
PR aprovado com relatório anexo.
Telemetria/Logs (temporários durante diagnóstico)
Logar uma linha por tentativa de login:

env/baseUrl, endpoint, method, headers relevantes (ofuscar Authorization), body keys (ofuscar password).
statusCode, trecho do body em falha (até 200 chars), erro de rede (classe/mensagem).
Remover logs verbosos após fix.

Modelo de Relatório (entregar preenchido)
1) Resumo executivo Problema, impacto, como foi resolvido.

2) Causa raiz (Root Cause Analysis)

Onde estava o defeito (arquivo/linha/camada).
Diferença crítica Postman × App (headers/body/url/config).
Por que só afetava desktop Windows (se aplicável).
3) Evidências

cURL do Postman (sanitizado).
cURL/log da requisição do app antes e depois (sanitizado).
Prints/logs de erro (TLS/validação/mapeamento).
4) Correções aplicadas

Lista de arquivos e mudanças (com trechos de diff).
Ajustes em config/env/flavor.
Remoção/adição de interceptors/headers.
5) Testes

Manuais (passo a passo de reprodução).
Unitários/integração adicionados/atualizados (como rodar e expected).
6) Riscos e follow-ups

Possíveis impactos colaterais e mitigação.
Itens para backlog (ex.: teste e2e no Windows CI, verificação de certificado em runtime, alerta de env incorreto).
Dicas de verificação rápida (checklist)
username não é convertido para lowercase nem tem _ removido.
Content-Type: application/json e Accept: application/json presentes.
baseUrl/endpoint/path idênticos ao Postman (sem barra a mais/menos).
Corpo com mesmas chaves que a API exige (username vs email).
Sem hashing local de senha se a API espera texto puro.
Sem erro de TLS no Windows (CERTIFICATE_VERIFY_FAILED/HandshakeException).
Sem bloqueio por WAF/CDN devido a User-Agent/headers ausentes.
Limpeza de cache/token antes de novos testes.
Saída esperada do agente: PR com a correção + relatório completo preenchido + instruções curtas de QA para validação em produção com os três usuários de teste.