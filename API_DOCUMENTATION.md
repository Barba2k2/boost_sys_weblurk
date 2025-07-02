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
DATABASE_USER=your_user
DATABASE_PASSWORD=your_password
DATABASE_NAME=boost_twitch
DATABASE_PORT=5432
DATABASE_SSL=false

# Alternative database variable names (also supported)
databaseHost=localhost
databaseUser=your_user
databasePassword=your_password
databaseName=boost_twitch
databasePort=5432
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

### Roles Disponíveis

- `admin`: Acesso completo a todos os endpoints
- `user`: Acesso básico

### PATCH `/auth/confirm`

Confirma o login e gera refresh token.

**Headers Obrigatórios:**

```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

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

**Response:**

```json
{
  "access_token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "refresh_token_here"
}
```

> O backend extrai automaticamente o userId, streamerId e role do JWT enviado no header Authorization. Não envie esses dados em headers separados.

---

### Exemplo de uso

```bash
# Confirmar login (web)
curl -X PATCH http://localhost:8000/auth/confirm \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "web_token": "web_token_here"
  }'

# Confirmar login (windows)
curl -X PATCH http://localhost:8000/auth/confirm \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "windows_token": "windows_token_here"
  }'
```

---

## 📡 Endpoints da API

### 🔑 Autenticação

#### POST `/auth/register`

Registra um novo usuário no sistema.

**Request Body:**

```json
{
  "nickname": "usuario123",
  "password": "senha123",
  "role": "user"
  // "role": "admin" // para criar um admin
}
```

**Response:**

```json
{
  "message": "User created successfully"
}
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

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### PUT `/auth/refresh`

Renova o token de acesso usando o refresh token.

**Headers Obrigatórios:**

```
access_token: current_access_token
```

**Request Body:**

```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response:**

```json
{
  "access_token": "new_access_token",
  "refresh_token": "new_refresh_token"
}
```

### 👤 Usuários

#### GET `/user/`

Obtém informações do usuário autenticado.

**Headers Obrigatórios:**

```http
Authorization: access_token
```

**Response:**

```json
{
  "id": 123,
  "nickname": "usuario123",
  "role": "user"
}
```

### 📅 Agendamentos

Agora os agendamentos estão separados em duas listas, cada uma com sua própria tabela e endpoints:

### Lista A

#### POST `/list-a/save`

Cria ou atualiza todos os agendamentos da Lista A.

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
    }
  ]
}
```

> **Observação:**
>
> - O campo `date` aceita tanto o formato `"yyyy-MM-dd"` quanto o formato ISO 8601 completo (`"2024-01-15T00:00:00.000Z"`).
> - O campo `list_name` **só é aceito como `lista_a` (sem espaços, minúsculo e com underscore)**. Qualquer outro valor (incluindo `Lista A`, `lista a`, etc.) será rejeitado com erro.
> - **O backend sempre salva e retorna o nome da lista como `lista_a`, independentemente do valor enviado pelo front.**

**Response:**

```json
{
  "message": "Lista A saved successfully"
}
```

#### GET `/list-a/`

Retorna todos os agendamentos da Lista A.

**Response:**

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

#### GET `/list-a/get?date=2024-01-15`

Retorna agendamentos da Lista A para uma data específica.

**Response:**

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

### Lista B

#### POST `/list-b/save`

Cria ou atualiza todos os agendamentos da Lista B.

**Request Body:**

```json
{
  "list_name": "lista_b",
  "schedules": [
    {
      "streamer_url": "https://twitch.tv/streamer2",
      "date": "2024-01-15T00:00:00.000Z",
      "start_time": "22:00",
      "end_time": "23:00"
    }
  ]
}
```

> **Observação:**
>
> - O campo `date` aceita tanto o formato `"yyyy-MM-dd"` quanto o formato ISO 8601 completo (`"2024-01-15T00:00:00.000Z"`).
> - O campo `list_name` **só é aceito como `lista_b` (sem espaços, minúsculo e com underscore)**. Qualquer outro valor (incluindo `Lista B`, `lista b`, etc.) será rejeitado com erro.
> - **O backend sempre salva e retorna o nome da lista como `lista_b`, independentemente do valor enviado pelo front.**

**Response:**

```json
{
  "message": "Lista B saved successfully"
}
```

#### GET `/list-b/`

Retorna todos os agendamentos da Lista B.

**Response:**

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

#### GET `/list-b/get?date=2024-01-15`

Retorna agendamentos da Lista B para uma data específica.

**Response:**

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

#### GET `/list-a/lists` ou `/list-b/lists`

Retorna os nomes das listas disponíveis:

**Response:**

```json
{
  "list_names": ["Lista A", "Lista B"]
}
```

### 🏆 Pontuações

#### GET `/score/`

Obtém pontuações (requer autenticação).

**Headers Obrigatórios:**

```http
Authorization: Bearer <token>
```

**Query Parameters:**

- `date`: Data específica (opcional)

**Response:**

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

#### POST `/score/save`

Salva uma nova pontuação (requer autenticação).

**Headers Obrigatórios:**

```http
Authorization: Bearer <token>
```

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

#### DELETE `/score/delete/<streamerId>`

Deleta uma pontuação (requer autenticação).

**Headers Obrigatórios:**

```http
Authorization: Bearer <token>
```

**Request Body:**

```json
{
  "date": "2024-01-15",
  "hour": 20
}
```

### 🌐 Pontuações Públicas

#### GET `/public/score/`

Obtém pontuações com filtros avançados (sem autenticação).

**Query Parameters:**

- `nickname`: Nome do streamer
- `startDate`: Data inicial
- `endDate`: Data final
- `startHour`: Hora inicial
- `endHour`: Hora final

**Exemplo:**

```
GET /public/score/?nickname=streamer123&startDate=2024-01-01&endDate=2024-01-31
```

### 📊 Status de Streamers

#### POST `/streamer/status/update`

Atualiza o status de um streamer.

**Request Body:**

```json
{
  "streamerId": 101,
  "status": "ON"
}
```

**Valores de Status:**

- `"ON"`: Streamer online
- `"OFF"`: Streamer offline

**Response:**

```json
{
  "message": "Status updated successfully"
}
```

#### GET `/streamer/status/current`

Obtém o status atual de todos os streamers.

**Response:**

```json
[
  {
    "streamerId": 101,
    "nickname": "streamer123",
    "status": "online",
    "last_login": "2024-01-15T20:00:00.000Z",
    "last_login_date": "15/01/2024",
    "last_login_time": "20:00"
  }
]
```

### 👨‍💻 Gerenciamento de Streamers

#### POST `/streamers/save`

Cria um novo streamer (requer role admin).

**Headers Obrigatórios:**

```http
Authorization: Bearer <admin_token>
```

**Request Body:**

```json
{
  "nickname": "streamer123",
  "password": "senha123",
  "role": "user", // "admin" para criar um admin
  // Campos opcionais:
  "fullName": "Nome do Streamer",
  "email": "streamer@exemplo.com",
  "phone": "11999999999",
  "platforms": ["twitch", "youtube"],
  "usualStartTime": "20:00",
  "usualEndTime": "22:00",
  "streamDays": ["segunda", "terça", "quarta"],
  "twitchChannel": "streamer123",
  "youtubeChannel": "streamer123",
  "instagramHandle": "@streamer123",
  "tiktokHandle": "@streamer123",
  "facebookPage": "streamer123"
}
```

#### GET `/streamers/`

Lista todos os streamers (requer role admin).

**Headers Obrigatórios:**

```http
Authorization: Bearer <admin_token>
```

**Response:**

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

#### PUT `/streamers/update/<id>`

Atualiza dados de um streamer (requer role admin).

**Headers Obrigatórios:**

```http
Authorization: Bearer <admin_token>
```

#### DELETE `/streamers/delete/<id>`

Remove um streamer (requer role admin).

**Headers Obrigatórios:**

```http
Authorization: Bearer <admin_token>
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

### Schedule

```json
{
  "id": 1,
  "streamerUrl": "https://twitch.tv/streamer123",
  "date": "2024-01-15T00:00:00.000Z",
  "startTime": "20:00",
  "endTime": "22:00",
  "listName": "Lista A"
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
  "phone": "11999999999"
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
curl -X POST http://localhost:8000/schedules/save \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "streamerUrl": "https://twitch.tv/streamer123",
    "date": "2024-01-15T00:00:00.000Z",
    "startTime": "20:00",
    "endTime": "22:00"
  }'
```

### Exemplo de Consulta de Pontuações

```bash
# Pontuações públicas com filtros
curl "http://localhost:8000/public/score/?nickname=streamer123&startDate=2024-01-01&endDate=2024-01-31"

# Pontuações autenticadas
curl -X GET http://localhost:8000/score/ \
  -H "Authorization: Bearer <token>"
```

### Exemplo de Gerenciamento de Streamer

```bash
# Criar streamer (requer admin)
curl -X POST http://localhost:8000/streamers/save \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{
    "nickname": "streamer123",
    "password": "senha123",
    "fullName": "Nome do Streamer",
    "email": "streamer@exemplo.com",
    "platforms": ["twitch"]
  }'
```

### Exemplo de Atualização de Status

```bash
curl -X POST http://localhost:8000/streamer/status/update \
  -H "Content-Type: application/json" \
  -d '{
    "streamerId": 101,
    "status": "ON"
  }'
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

**Versão da API:** 1.0.0  
**Porta Padrão:** 8000  
**Última atualização:** Janeiro 2024
