# AutoCare.Network

Pacote SPM com a camada de rede do AutoCare, seguindo o mesmo padrão do [GameNet.Network](https://github.com/allistoncarlos/GameNet.Network).

## Conteúdo previsto

- `DataProviders/API` — `NetworkManager`, `AutoCareAPI`, DTOs
- `Domain/Entities` — modelos de domínio
- `Keychain` — `KeychainDataSource`

## Integração no Xcode

1. File → Add Package Dependencies → Add Local...
2. Selecione a pasta `AutoCare.Network`
3. Adicione o produto `AutoCare.Network` ao target AutoCare
4. Substitua imports no app por `import AutoCare_Network`

A branch `arch/migration` mantém o código espelhado no app enquanto o pacote é finalizado para extração completa.
