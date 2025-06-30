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
7. [WebSockets](#websockets)
8. [Exemplos de Uso](#exemplos-de-uso)

---

## 🎯 Visão Geral

A API BoostTwitch é uma aplicação backend desenvolvida em Dart utilizando o framework Shelf, projetada para gerenciar streamers, agendamentos, pontuações e autenticação de usuários. A API oferece funcionalidades completas para plataformas de streaming com sistema de pontuação integrado.

### 🚀 Características Principais

- **Autenticação JWT**: Sistema seguro de autenticação com tokens
- **Gerenciamento de Usuários**: CRUD completo para usuários e streamers
- **Sistema de Agendamentos**: Gerenciamento de horários de stream
- **Sistema de Pontuação**: Controle de pontuações por streamer
- **WebSockets**: Comunicação em tempo real
- **Autorização Baseada em Roles**: Controle de acesso por perfil
- **Docker**: Containerização completa da aplicação

---

## ⚙️ Configuração e Instalação

### Pré-requisitos

- Dart SDK ^3.4.0
- PostgreSQL
- Docker (opcional)

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

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
```

### Executando com Dart

```bash
# Instalar dependências
dart pub get

# Executar a aplicação
dart run bin/server.dart
```

### Executando com Docker

```bash
# Construir a imagem
docker build . -t boost-api

# Executar o container
docker run -it -p 8080:8080 boost-api
```

---

## 🔐 Autenticação

A API utiliza autenticação JWT (JSON Web Token) com sistema de refresh tokens. Todos os endpoints protegidos requerem o header `Authorization: Bearer <token>`.

### Fluxo de Autenticação

1. **Login**: POST `/auth/login`
2. **Confirmação**: PATCH `/auth/confirm`
3. **Refresh**: PUT `/auth/refresh`

### Headers de Autenticação

```http
Authorization: Bearer <jwt_token>
id: <user_id>
streamerId: <streamer_id>
role: <user_role>
```

### Roles Disponíveis

- `admin`: Acesso completo a todos os endpoints
- `streamer`: Acesso limitado a funcionalidades de streamer
- `user`: Acesso básico

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
  "fullName": "Nome Completo",
  "email": "email@exemplo.com",
  "phone": "11999999999"
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

#### PATCH `/auth/confirm`

Confirma o login e gera refresh token.

**Headers:**

```http
id: 123
streamerId: 456
role: user
```

**Request Body:**

```json
{
  "webToken": "web_token_here",
  "windowsToken": "windows_token_here"
}
```

**Response:**

```json
{
  "access_token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "refresh_token_here"
}
```

#### PUT `/auth/refresh`

Renova o token de acesso usando o refresh token.

**Headers:**

```http
id: 123
streamerId: 456
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

**Headers:**

```http
Authorization: Bearer <token>
id: 123
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

#### POST `/schedules/save`

Cria um novo agendamento.

**Request Body (Agendamento Único):**

```json
{
  "streamerUrl": "https://twitch.tv/streamer123",
  "date": "2024-01-15T00:00:00.000Z",
  "startTime": "20:00",
  "endTime": "22:00"
}
```

**Request Body (Múltiplos Agendamentos):**

```json
[
  {
    "streamerUrl": "https://twitch.tv/streamer123",
    "date": "2024-01-15T00:00:00.000Z",
    "startTime": "20:00",
    "endTime": "22:00"
  },
  {
    "streamerUrl": "https://twitch.tv/streamer456",
    "date": "2024-01-15T00:00:00.000Z",
    "startTime": "21:00",
    "endTime": "23:00"
  }
]
```

**Response:**

```json
{
  "message": "Schedule created successfully"
}
```

#### POST `/schedules/save-list`

Cria uma lista de agendamentos.

**Request Body:**

```json
{
  "listName": "Agenda Semanal",
  "schedules": [
    {
      "streamerUrl": "https://twitch.tv/streamer123",
      "date": "2024-01-15T00:00:00.000Z",
      "startTime": "20:00",
      "endTime": "22:00"
    }
  ]
}
```

#### GET `/schedules/`

Lista todos os agendamentos.

**Response:**

```json
[
  {
    "id": 1,
    "streamer_url": "https://twitch.tv/streamer123",
    "date": "2024-01-15T00:00:00.000Z",
    "start_time": "20:00",
    "end_time": "22:00"
  }
]
```

#### GET `/schedules/get?date=2024-01-15`

Obtém agendamentos por data específica.

**Response:**

```json
[
  {
    "list_name": "Agenda Semanal",
    "schedules": [
      {
        "id": 1,
        "streamer_url": "https://twitch.tv/streamer123",
        "date": "2024-01-15T00:00:00.000Z",
        "start_time": "20:00",
        "end_time": "22:00"
      }
    ]
  }
]
```

#### GET `/schedules/list?name=Agenda Semanal`

Obtém agendamentos por nome da lista.

#### GET `/schedules/lists`

Lista todos os nomes de listas de agendamentos.

**Response:**

```json
["Agenda Semanal", "Agenda Mensal"]
```

#### POST `/schedules/update`

Atualiza agendamentos existentes.

#### POST `/schedules/update-list`

Atualiza uma lista de agendamentos.

#### POST `/schedules/force-update`

Força atualização via WebSocket para todos os clientes conectados.

### 🏆 Pontuações

#### GET `/score/`

Obtém pontuações (requer autenticação).

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

**Request Body:**

```json
{
  "streamerId": 101,
  "date": "2024-01-15T00:00:00.000Z",
  "hour": 20,
  "minute": 30,
  "points": 150,
  "nickname": "streamer123"
}
```

#### DELETE `/score/delete/<streamerId>`

Deleta uma pontuação (requer autenticação).

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
    "id": 101,
    "nickname": "streamer123",
    "status": true,
    "lastLogin": "2024-01-15T20:00:00.000Z"
  }
]
```

### 👨‍💻 Gerenciamento de Streamers

#### POST `/streamers/save`

Cria um novo streamer (requer role admin).

**Request Body:**

```json
{
  "nickname": "streamer123",
  "password": "senha123",
  "fullName": "Nome do Streamer",
  "email": "streamer@exemplo.com",
  "phone": "11999999999",
  "platforms": ["twitch", "youtube"],
  "usualStartTime": "20:00",
  "usualEndTime": "22:00",
  "streamDays": ["segunda", "terça", "quarta"]
}
```

#### GET `/streamers/`

Lista todos os streamers (requer role admin).

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

#### DELETE `/streamers/delete/<id>`

Remove um streamer (requer role admin).

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
  "listName": "Agenda Semanal"
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

## 🔌 WebSockets

A API suporta WebSockets para comunicação em tempo real, especialmente para notificações de atualizações de agendamentos.

### Endpoint WebSocket

```
ws://localhost:8080/ws
```

### Eventos Disponíveis

#### `schedule_update`

Notifica sobre atualizações de agendamentos.

**Payload:**

```json
{
  "type": "schedule_update",
  "data": {
    "schedules": [...]
  }
}
```

---

## 💡 Exemplos de Uso

### Exemplo Completo de Autenticação

```bash
# 1. Registrar usuário
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nickname": "usuario123",
    "password": "senha123",
    "fullName": "Nome Completo",
    "email": "email@exemplo.com"
  }'

# 2. Fazer login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "nickname": "usuario123",
    "password": "senha123"
  }'

# 3. Confirmar login
curl -X PATCH http://localhost:8080/auth/confirm \
  -H "Content-Type: application/json" \
  -H "id: 123" \
  -H "streamerId: 456" \
  -H "role: user" \
  -d '{
    "webToken": "web_token_here"
  }'
```

### Exemplo de Criação de Agendamento

```bash
curl -X POST http://localhost:8080/schedules/save \
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
curl "http://localhost:8080/public/score/?nickname=streamer123&startDate=2024-01-01&endDate=2024-01-31"

# Pontuações autenticadas
curl -X GET http://localhost:8080/score/ \
  -H "Authorization: Bearer <token>"
```

### Exemplo de Gerenciamento de Streamer

```bash
# Criar streamer (requer admin)
curl -X POST http://localhost:8080/streamers/save \
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

---

## 🛠️ Desenvolvimento

### Estrutura do Projeto

```
lib/
├── app/
│   ├── config/          # Configurações da aplicação
│   ├── database/        # Conexão com banco de dados
│   ├── exceptions/      # Exceções customizadas
│   ├── helpers/         # Utilitários
│   ├── logger/          # Sistema de logs
│   ├── middlewares/     # Middlewares da aplicação
│   ├── routers/         # Configuração de rotas
│   ├── utils/           # Utilitários gerais
│   └── websockets/      # Gerenciamento de WebSockets
├── entities/            # Entidades do banco de dados
└── modules/             # Módulos da aplicação
    ├── user/            # Módulo de usuários
    ├── schedules/       # Módulo de agendamentos
    ├── score/           # Módulo de pontuações
    ├── streamer_status/ # Módulo de status de streamers
    └── fetch_users/     # Módulo de gerenciamento de streamers
```

### Executando Testes

```bash
# Executar todos os testes
dart test

# Executar testes com cobertura
dart test --coverage=coverage
```

### Build e Deploy

```bash
# Gerar código
dart run build_runner build

# Executar com Docker
docker-compose up -d
```

---

## 📞 Suporte

Para dúvidas, sugestões ou problemas, entre em contato através dos canais oficiais do projeto.

---

**Versão da API:** 1.0.0  
**Última atualização:** Janeiro 2024
