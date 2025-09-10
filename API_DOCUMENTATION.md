# 📚 Documentação Completa da API BoostTwitch

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Configuração e Instalação](#configuração-e-instalação)
3. [Autenticação](#autenticação)
4. [Endpoints da API](#endpoints-da-api)
   - [Autenticação](#autenticação-1)
   - [Usuários](#usuários)
   - [Agendamentos](#agendamentos)
   - [Pontuações](#pontuações)
   - [Status de Streamers](#status-de-streamers)
   - [Gerenciamento de Streamers](#gerenciamento-de-streamers)
   - [Health Check](#health-check)
5. [Modelos de Dados](#modelos-de-dados)
6. [Códigos de Status HTTP](#códigos-de-status-http)
7. [Exemplos de Uso](#exemplos-de-uso)
8. [Estrutura do Projeto](#estrutura-do-projeto)

---

## 🎯 Visão Geral

A API BoostTwitch é uma aplicação backend desenvolvida em Dart utilizando o framework Shelf, projetada para gerenciar streamers, agendamentos, pontuações e autenticação de usuários. A API oferece funcionalidades completas para plataformas de streaming com sistema de pontuação integrado.

### 🚀 Características Principais

- **Autenticação JWT**: Sistema seguro de autenticação com tokens
- **Gerenciamento de Usuários**: CRUD completo para usuários e streamers
- **Sistema de Agendamentos**: Gerenciamento de horários de stream
- **Sistema de Pontuação**: Controle de pontuações por streamer
- **Autorização Baseada em Roles**: Controle de acesso por perfil
- **Arquitetura Modular**: Separação clara de responsabilidades

---

## ⚙️ Configuração e Instalação

### Pré-requisitos

- Dart SDK ^3.4.0
- PostgreSQL
- Git

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# Database Configuration
DATABASE_HOST=localhost
DATABASE_USER=boost_twitch
DATABASE_PASSWORD=BoostTwitch2024
DATABASE_NAME=boost_twitch
DATABASE_PORT=5433
DATABASE_SSL=false

# Alternative database variable names (also supported)
databaseHost=localhost
databaseUser=boost_twitch
databasePassword=BoostTwitch2024
databaseName=boost_twitch
databasePort=5433

# JWT Configuration
JWT_SECRET=8VpVR43ycV2MU79bnoC1
```

**Nota:** Para desenvolvimento local, certifique-se de que o PostgreSQL esteja rodando na porta 5433. Se estiver usando Docker, execute:

```bash
docker run --name boost_db -e POSTGRES_USER=boost_twitch -e POSTGRES_PASSWORD=BoostTwitch2024 -e POSTGRES_DB=boost_twitch -p 5433:5432 -d postgres:15
```

### Executando com Dart

```bash
# Instalar dependências
dart pub get

# Gerar código (se necessário)
dart run build_runner build

# Executar a aplicação
dart run bin/server.dart
```

### Executando Testes

```bash
# Executar todos os testes
dart test

# Executar testes com cobertura
dart test --coverage=coverage
```

---

## 🔐 Autenticação

A API utiliza autenticação JWT (JSON Web Token) com sistema de refresh tokens. Todos os endpoints protegidos requerem o header `Authorization: Bearer <token>`.

### Fluxo de Autenticação

1. **Registro**: POST `/auth/register`
2. **Login**: POST `/auth/login`
3. **Confirmação**: PATCH `/auth/confirm`
4. **Refresh**: PUT `/auth/refresh`

#### Roles Disponíveis

- `admin`: Acesso completo a todos os endpoints
- `user`: Acesso básico

#### Fluxo Completo

1. **Registrar usuário**
2. **Fazer login** (recebe access_token)
3. **Confirmar login** (recebe refresh_token)
4. **Renovar token** (com refresh_token)

#### Headers Obrigatórios

- `Authorization: Bearer <access_token>` (para endpoints protegidos)
- `Content-Type: application/json`

#### Endpoints Públicos (Sem Autenticação)

Os seguintes endpoints podem ser acessados sem autenticação:

- `GET /health` - Health check da API
- `POST /auth/register` - Registro de usuário
- `POST /auth/login` - Login de usuário
- `GET /public/score` - Consulta pública de pontuações

#### Exemplos de Erro

- 400: Dados inválidos
- 401: Token ausente ou inválido
- 403: Permissão insuficiente
- 500: Erro interno

---

## 📡 Endpoints da API

### 🔑 Autenticação

#### POST `/auth/register`

Registra um novo usuário.

**Request Body:**

```json
{
  "nickname": "usuario123",
  "password": "senha123",
  "role": "user"
}
```

**Response 200:**

```json
{ "message": "User created successfully" }
```

**Response 400:**

```json
{ "message": "User already exists on database" }
```

#### POST `/auth/login`

Realiza login do usuário e retorna um token de acesso.

**Request Body:**

```json
{
  "nickname": "usuario123",
  "password": "senha123"
}
```

**Response 200:**

```json
{ "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." }
```

**Response 403:**

```json
{ "message": "User not found" }
```

#### PATCH `/auth/confirm`

Confirma o login e gera refresh token.

**Headers obrigatórios:**

- `Authorization: Bearer <access_token>`
- `Content-Type: application/json`

**Request Body:**

```json
{
  "web_token": "web_token_here"
}
```

ou

```json
{
  "windows_token": "windows_token_here"
}
```

**Response 200:**

```json
{
  "access_token": "Bearer <access_token>",
  "refresh_token": "<refresh_token>"
}
```

**Response 400:**

```json
{ "message": "No token received" }
```

**Response 401:**

```json
{ "message": "Missing or invalid Authorization header" }
```

**Response 500:**

```json
{ "message": "Error on confirm login" }
```

#### PUT `/auth/refresh`

Renova o token de acesso usando o refresh token.

**Headers Obrigatórios:**

- `id: <user_id>`
- `streamerId: <streamer_id>` (opcional)
- `access_token: <access_token>`
- `Content-Type: application/json`

**Request Body:**

```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response 200:**

```json
{
  "access_token": "new_access_token",
  "refresh_token": "new_refresh_token"
}
```

**Response 500:**

```json
{ "message": "Error on refresh token" }
```

### 👤 Usuários

#### GET `/user`

Obtém informações do usuário autenticado.

**Headers obrigatórios:**

- `Authorization: Bearer <access_token>`
- `id: <user_id>` (obrigatório no header)

**Response 200:**

```json
{
  "id": 123,
  "nickname": "usuario123",
  "role": "user"
}
```

### 📅 Agendamentos

O sistema suporta duas listas de agendamentos separadas: Lista A e Lista B, cada uma com seus próprios endpoints.

#### Lista A

##### POST `/list-a`

Cria agendamento(s) na Lista A.

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "list_name": "lista_a",
  "schedules": [
    {
      "streamer_url": "https://twitch.tv/streamer1",
      "date": "2024-01-15",
      "start_time": "21:00",
      "end_time": "22:00"
    },
    {
      "streamer_url": "https://twitch.tv/streamer2",
      "date": "2024-01-15",
      "start_time": "22:00",
      "end_time": "23:00"
    }
  ]
}
```

**Response 200:**

```json
{ "message": "Schedules created successfully" }
```

**Response 400:**

```json
{ "message": "Invalid format. Use object with list_name and schedules key." }
```

##### GET `/list-a`

Retorna agendamentos da Lista A. Aceita filtro opcional por data.

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Query Parameters:**

- `date`: Data específica (opcional) - formato: `YYYY-MM-DD`

**Exemplos:**

```
GET /list-a                    # Todos os agendamentos
GET /list-a?date=2024-01-15   # Agendamentos de uma data específica
```

**Response 200:**

```json
{
  "list_name": "lista_a",
  "schedules": [
    {
      "id": 1,
      "streamer_url": "https://twitch.tv/streamer1",
      "date": "2024-01-15T00:00:00.000Z",
      "start_time": "21:00",
      "end_time": "22:00"
    }
  ]
}
```

#### Lista B

##### POST `/list-b`

Cria agendamento(s) na Lista B.

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "list_name": "lista_b",
  "schedules": [
    {
      "streamer_url": "https://twitch.tv/streamer2",
      "date": "2024-01-15",
      "start_time": "22:00",
      "end_time": "23:00"
    }
  ]
}
```

**Response 200:**

```json
{ "message": "Schedules created successfully" }
```

##### GET `/list-b`

Retorna agendamentos da Lista B. Aceita filtro opcional por data.

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Query Parameters:**

- `date`: Data específica (opcional) - formato: `YYYY-MM-DD`

**Exemplos:**

```
GET /list-b                    # Todos os agendamentos
GET /list-b?date=2024-01-15   # Agendamentos de uma data específica
```

**Response 200:**

```json
{
  "list_name": "lista_b",
  "schedules": [
    {
      "id": 1,
      "streamer_url": "https://twitch.tv/streamer2",
      "date": "2024-01-15T00:00:00.000Z",
      "start_time": "22:00",
      "end_time": "23:00"
    }
  ]
}
```

### 🏆 Pontuações

#### GET `/score`

Obtém pontuações (requer autenticação).

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Query Parameters:**

- `date`: Data específica (opcional)

**Response 200:**

```json
[
  {
    "id": 1,
    "streamerId": 101,
    "date": "2024-01-15T00:00:00.000Z",
    "hour": 20,
    "minute": 30,
    "points": 150,
    "nickname": "streamer123"
  }
]
```

#### POST `/score`

Salva uma nova pontuação (requer autenticação).

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "streamerId": 101,
  "date": "2024-01-15T00:00:00.000Z",
  "hour": 20,
  "minute": 30,
  "points": 150
}
```

**Response 200:**

```json
{ "message": "Score saved successfully" }
```

#### DELETE `/score/<streamerId>`

Deleta uma pontuação (requer autenticação).

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "date": "2024-01-15",
  "hour": 20
}
```

**Response 200:**

```json
{ "message": "Score deleted successfully" }
```

### 🌐 Pontuações Públicas

#### GET `/public/score`

Obtém pontuações com filtros avançados (sem autenticação).

**Query Parameters:**

- `nickname`: Nome do streamer
- `startDate`: Data inicial
- `endDate`: Data final
- `startHour`: Hora inicial
- `endHour`: Hora final

**Response 200:**

```json
[
  {
    "id": 1,
    "streamerId": 101,
    "date": "2024-01-15T00:00:00.000Z",
    "hour": 20,
    "minute": 30,
    "points": 150,
    "nickname": "streamer123"
  }
]
```

### 📊 Status de Streamers

#### GET `/streamers/status`

Obtém o status atual de todos os streamers cadastrados no sistema.

**Headers Obrigatórios:**

- `Authorization: Bearer <token>`

**Response 200:**

```json
[
  {
    "streamerId": 1,
    "nickname": "admin",
    "status": "online",
    "last_login": "2024-01-15T20:00:00.000Z",
    "last_login_date": "15/01/2024",
    "last_login_time": "20:00"
  },
  {
    "streamerId": 2,
    "nickname": "streamer123",
    "status": "offline",
    "last_login": null,
    "last_login_date": null,
    "last_login_time": null
  }
]
```

**Campos da Resposta:**

- `streamerId` (number): ID único do streamer
- `nickname` (string): Nome de usuário do streamer
- `status` (string): Status atual - `"online"` ou `"offline"`
- `last_login` (string|null): Data e hora do último login em formato ISO 8601
- `last_login_date` (string|null): Data do último login no formato DD/MM/YYYY
- `last_login_time` (string|null): Hora do último login no formato HH:MM

**Observações:**

- O campo `status` é baseado no valor booleano `status` do streamer no banco de dados
- Campos de data podem ser `null` se o streamer nunca fez login
- A resposta sempre retorna um array, mesmo que vazio

### 👨‍💻 Gerenciamento de Streamers

#### POST `/streamers`

Cria um novo streamer (requer role admin).

**Headers Obrigatórios:**

- `Authorization: Bearer <admin_token>`

**Request Body:**

**Campos Obrigatórios:**

- `nickname` (string): Nome de usuário do streamer
- `password` (string): Senha do streamer
- `role` (string): Role do usuário (`user`, `admin`, etc.)

**Campos Opcionais:**

```json
{
  "nickname": "streamer123",
  "password": "senha123",
  "role": "user",
  "fullName": "Nome do Streamer",
  "email": "streamer@exemplo.com",
  "phone": "11999999999",
  "platforms": ["twitch"],
  "usualStartTime": "20:00",
  "usualEndTime": "22:00",
  "streamDays": ["segunda", "terça", "quarta"],
  "twitchChannel": "https://twitch.tv/streamer123",
  "youtubeChannel": "https://youtube.com/streamer123",
  "instagramHandle": "@streamer123",
  "tiktokHandle": "@streamer123",
  "facebookPage": "https://facebook.com/streamer123"
}
```

**Response 200:**

```json
{ "message": "Streamer created successfully" }
```

#### GET `/streamers`

Lista todos os streamers (requer role admin).

**Headers Obrigatórios:**

- `Authorization: Bearer <admin_token>`

**Response 200:**

```json
[
  {
    "id": 101,
    "nickname": "streamer123",
    "role": "streamer",
    "platform": "twitch",
    "status": "Ativo"
  }
]
```

#### PUT `/streamers/<id>`

Atualiza dados de um streamer (requer role admin).

**Headers Obrigatórios:**

- `Authorization: Bearer <admin_token>`

**Request Body:**

**Campos Obrigatórios:**

- `nickname` (string): Nome de usuário do streamer
- `role` (string): Role do usuário (`user`, `admin`, etc.)

**Campos Opcionais:**

```json
{
  "nickname": "streamer123_updated",
  "role": "user",
  "password": "nova_senha_123",
  "fullName": "Nome Atualizado do Streamer",
  "email": "streamer_updated@exemplo.com",
  "phone": "11999999999",
  "platforms": ["twitch", "youtube"],
  "usualStartTime": "21:00",
  "usualEndTime": "23:00",
  "streamDays": ["segunda", "terça", "quinta"],
  "twitchChannel": "https://twitch.tv/streamer123_updated",
  "youtubeChannel": "https://youtube.com/streamer123_updated",
  "instagramHandle": "@streamer123_updated",
  "tiktokHandle": "@streamer123_updated",
  "facebookPage": "https://facebook.com/streamer123_updated"
}
```

**Response 200:**

```json
{ "message": "Streamer updated successfully" }
```

#### DELETE `/streamers/<id>`

Remove um streamer (requer role admin).

**Headers Obrigatórios:**

- `Authorization: Bearer <admin_token>`

**Response 200:**

```json
{ "message": "Streamer deleted successfully" }
```

### 🔍 Health Check

#### GET `/health`

Verifica se a API está funcionando corretamente.

**Observação:** Este endpoint não requer autenticação.

**Response 200:**

```
OK
```

---

## 📊 Modelos de Dados

### User

```json
{
  "id": 123,
  "nickname": "usuario123",
  "password": "senha_hash",
  "role": "user",
  "streamerId": 456,
  "refreshToken": "refresh_token",
  "webToken": "web_token",
  "windowsToken": "windows_token",
  "fullName": "Nome Completo",
  "email": "email@exemplo.com",
  "phone": "11999999999"
}
```

### List A Schedule / List B Schedule

```json
{
  "id": 1,
  "streamerUrl": "https://twitch.tv/streamer123",
  "date": "2024-01-15T00:00:00.000Z",
  "startTime": "20:00",
  "endTime": "22:00"
}
```

### Score

```json
{
  "id": 1,
  "streamerId": 101,
  "date": "2024-01-15T00:00:00.000Z",
  "hour": 20,
  "minute": 30,
  "points": 150,
  "nickname": "streamer123"
}
```

### Streamer

```json
{
  "id": 101,
  "nickname": "streamer123",
  "password": "senha_hash",
  "lastLogin": "2024-01-15T20:00:00.000Z",
  "status": true,
  "role": "streamer",
  "platforms": ["twitch", "youtube"],
  "usualStartTime": "20:00",
  "usualEndTime": "22:00",
  "streamDays": ["segunda", "terça", "quarta"],
  "userId": 123,
  "fullName": "Nome do Streamer",
  "email": "streamer@exemplo.com",
  "phone": "11999999999",
  "socialMedia": {
    "id": 1,
    "streamerId": 101,
    "twitchChannel": "twitch_channel_url",
    "youtubeChannel": "youtube_channel_url",
    "instagramHandle": "@instagram_handle",
    "tiktokHandle": "@tiktok_handle",
    "facebookPage": "facebook_page_url"
  }
}
```

### Social Media

```json
{
  "id": 1,
  "streamerId": 101,
  "twitchChannel": "twitch_channel_url",
  "youtubeChannel": "youtube_channel_url",
  "instagramHandle": "@instagram_handle",
  "tiktokHandle": "@tiktok_handle",
  "facebookPage": "facebook_page_url"
}
```

---

## 📋 Códigos de Status HTTP

| Código | Descrição             | Uso                               |
| ------ | --------------------- | --------------------------------- |
| 200    | OK                    | Requisição bem-sucedida           |
| 201    | Created               | Recurso criado com sucesso        |
| 400    | Bad Request           | Dados inválidos na requisição     |
| 401    | Unauthorized          | Token inválido ou ausente         |
| 403    | Forbidden             | Acesso negado (role insuficiente) |
| 404    | Not Found             | Recurso não encontrado            |
| 500    | Internal Server Error | Erro interno do servidor          |

---

## 💡 Exemplos de Uso

### Exemplo Completo de Autenticação

```bash
# 1. Registrar usuário
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nickname": "usuario123",
    "password": "senha123",
    "fullName": "Nome Completo",
    "email": "email@exemplo.com"
  }'

# 2. Fazer login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "nickname": "usuario123",
    "password": "senha123"
  }'

# 3. Confirmar login (web)
curl -X PATCH http://localhost:8000/auth/confirm \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "web_token": "web_token_here"
  }'

# 3b. Confirmar login (windows)
curl -X PATCH http://localhost:8000/auth/confirm \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "windows_token": "windows_token_here"
  }'
```

### Exemplo de Criação de Agendamento

```bash
curl -X POST http://localhost:8000/list-a \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "list_name": "lista_a",
    "schedules": [
      {
        "streamer_url": "https://twitch.tv/streamer123",
        "date": "2024-01-15",
        "start_time": "20:00",
        "end_time": "22:00"
      }
    ]
  }'
```

### Exemplo de Consulta de Pontuações

```bash
# Pontuações públicas com filtros
curl "http://localhost:8000/public/score?nickname=streamer123&startDate=2024-01-01&endDate=2024-01-31"

# Pontuações autenticadas
curl -X GET http://localhost:8000/score \
  -H "Authorization: Bearer <token>"
```

### Exemplo de Gerenciamento de Streamer

```bash
# Criar streamer (requer admin)
curl -X POST http://localhost:8000/streamers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{
    "nickname": "streamer123",
    "password": "senha123",
    "role": "user",
    "fullName": "Nome do Streamer",
    "email": "streamer@exemplo.com",
    "phone": "11999999999",
    "platforms": ["twitch"],
    "usualStartTime": "20:00",
    "usualEndTime": "22:00",
    "streamDays": ["segunda", "terça", "quarta"]
  }'

# Atualizar streamer (requer admin) - nickname e role são obrigatórios
curl -X PUT http://localhost:8000/streamers/101 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{
    "nickname": "streamer123_updated",
    "role": "user",
    "password": "nova_senha_123",
    "fullName": "Nome Atualizado do Streamer",
    "email": "streamer_updated@exemplo.com",
    "phone": "11999999999",
    "platforms": ["twitch", "youtube"],
    "usualStartTime": "21:00",
    "usualEndTime": "23:00",
    "streamDays": ["segunda", "terça", "quinta"],
    "twitchChannel": "https://twitch.tv/streamer123_updated"
  }'
```

### Exemplo de Health Check

```bash
curl -X GET http://localhost:8000/health
```

**Response:**

```
OK
```

### Exemplo de Consulta de Status de Streamers

```bash
# Consultar status de todos os streamers
curl -X GET http://localhost:8000/streamers/status \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json"
```

**Response:**

```json
[
  {
    "streamerId": 1,
    "nickname": "admin",
    "status": "online",
    "last_login": "2024-01-15T20:00:00.000Z",
    "last_login_date": "15/01/2024",
    "last_login_time": "20:00"
  },
  {
    "streamerId": 2,
    "nickname": "streamer123",
    "status": "offline",
    "last_login": null,
    "last_login_date": null,
    "last_login_time": null
  }
]
```

---

## 🛠️ Estrutura do Projeto

```
lib/
├── core/                    # Núcleo da aplicação
│   ├── config/             # Configurações da aplicação
│   ├── database/           # Conexão com banco de dados
│   ├── exceptions/         # Exceções customizadas
│   ├── helpers/            # Utilitários
│   ├── logger/             # Sistema de logs
│   ├── middlewares/        # Middlewares da aplicação
│   ├── routers/            # Configuração de rotas
│   ├── utils/              # Utilitários gerais
│   └── websockets/         # Gerenciamento de WebSockets
├── entities/               # Entidades do banco de dados
└── modules/                # Módulos da aplicação
    ├── user/               # Módulo de usuários
    ├── schedules/          # Módulo de agendamentos
    ├── score/              # Módulo de pontuações
    ├── streamer_status/    # Módulo de status de streamers
    └── fetch_users/        # Módulo de gerenciamento de streamers
```

### Tecnologias Utilizadas

- **Backend**: Dart + Shelf Framework
- **Banco de Dados**: PostgreSQL
- **Autenticação**: JWT (jaguar_jwt)
- **Injeção de Dependência**: GetIt + Injectable
- **Logs**: Logger package
- **Testes**: Dart Test Framework

### Executando o Projeto

```bash
# Instalar dependências
dart pub get

# Gerar código
dart run build_runner build

# Executar testes
dart test

# Executar a aplicação
dart run bin/server.dart
```

---

## 📞 Suporte

Para dúvidas, sugestões ou problemas, entre em contato através dos canais oficiais do projeto.

---

**Versão da API:** 1.0.1  
**Porta Padrão:** 8000  
**Última atualização:** Setembro 2025
