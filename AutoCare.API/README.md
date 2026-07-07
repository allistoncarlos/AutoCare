# AutoCare.API

Backend ASP.NET Core para o app AutoCare, alinhado aos endpoints consumidos pelo cliente iOS (`AutoCareAPI`).

## Endpoints

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/user/login` | Autenticação |
| POST | `/user/refresh` | Refresh token |
| GET | `/autocare/vehicleType` | Tipos de veículo |
| GET | `/autocare/vehicle` | Lista de veículos |
| GET | `/autocare/vehicle/{id}` | Veículo por id |
| POST | `/autocare/vehicle` | Criar veículo |
| PUT | `/autocare/vehicle/{id}` | Atualizar veículo |
| GET | `/autocare/vehicleMileage/{vehicleId}` | Abastecimentos |
| POST | `/autocare/vehicleMileage` | Criar abastecimento |
| PUT | `/autocare/vehicleMileage/{id}` | Atualizar abastecimento |
| GET | `/autocare/vehicleService/{vehicleId}` | Serviços |
| POST | `/autocare/vehicleService` | Criar serviço |
| PUT | `/autocare/vehicleService/{id}` | Atualizar serviço |

## Executar localmente

```bash
cd AutoCare.API
dotnet restore
dotnet run
```

A API sobe em `http://localhost:5000` (ou porta configurada). Configure `API_PATH` no `Config.xcconfig` do iOS para apontar para essa URL.

## Credenciais de desenvolvimento

- Usuário: `admin`
- Senha: `admin`

## Armazenamento

A implementação atual usa armazenamento em memória (`AutoCareStore`) para desenvolvimento e testes offline-first. Substitua por MongoDB ou outro provider conforme necessário.
