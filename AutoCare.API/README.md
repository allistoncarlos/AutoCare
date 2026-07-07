# AutoCare API (NestJS)

API REST do AutoCare baseada na arquitetura **FinanceHealth-api**: NestJS 10, MongoDB (Mongoose), autenticação JWT e sincronização incremental offline-first.

## Requisitos

- Node.js 20+
- MongoDB

## Configuração

```bash
cp .env.example .env
npm install
npm run start:dev
```

Variáveis em `.env`:

| Variável | Descrição |
|----------|-----------|
| `PORT` | Porta HTTP (padrão: 3000) |
| `DATABASE_URL` | Connection string MongoDB |
| `JWT_SECRET` | Segredo do JWT |
| `JWT_EXPIRES_IN` | Expiração do access token (ex: `8h`) |

## Credenciais padrão

- **Usuário:** `admin`
- **Senha:** `admin`

## Endpoints principais

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/auth/login` | Login |
| POST | `/auth/refresh` | Renovar token |
| GET | `/changes?since=` | Sync incremental |
| GET | `/vehicle-type` | Tipos de veículo |
| GET/POST/PUT/DELETE | `/vehicle` | Veículos |
| GET/POST/PUT/DELETE | `/vehicle-mileage?vehicleId=` | Abastecimentos |
| GET/POST/PUT/DELETE | `/vehicle-service?vehicleId=` | Serviços |

Documentação Swagger: `http://localhost:3000/api/docs`

## Sincronização

Entidades possuem `clientId`, `createdAt`, `updatedAt`, `deleted` e `deletedAt`. O endpoint `GET /changes?since=<ISO8601>` retorna alterações incrementais para o app iOS.

## Docker

```bash
docker build -t autocare-api .
docker run -p 3000:3000 -e DATABASE_URL=mongodb://host.docker.internal:27017/autocare autocare-api
```
