# 🎒 Survival Backpack

Sistema de gerenciamento de alimentos com controle de validade, rotação FIFO (First In, First Out) e notificações de vencimento. Desenvolvido como uma Progressive Web App (PWA) que funciona online e offline.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias](#tecnologias)
- [Funcionalidades](#funcionalidades)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Scripts Docker](#scripts-docker)
- [Documentação](#documentação)
- [Testes](#testes)
- [API](#api)
- [Estrutura do Projeto](#estrutura-do-projeto)

## 🎯 Sobre o Projeto

O **Survival Backpack** é uma aplicação web para gerenciar estoques de suprimentos com foco em:
- 📦 Controle de validade e alertas de vencimento
- 🔄 Sistema de rotação FIFO (First In, First Out)
- 🔔 Notificações push para alimentos próximos do vencimento
- 📱 PWA com suporte offline
- 🌐 API REST completa para integração

Ideal para famílias ou qualquer pessoa que queira otimizar o controle de alimentos e suprimentos e reduzir desperdícios.

## 🚀 Tecnologias

### Backend
- **Ruby** 3.4.7
- **Rails** 8.0.3
- **SQLite3** - Banco de dados
- **Puma** - Servidor web

### Frontend
- **Hotwire** (Turbo + Stimulus) - Framework frontend
- **Importmap** - Gerenciamento de JavaScript
- **Propshaft** - Asset pipeline

### Funcionalidades Especiais
- **WebPush** - Notificações push
- **Kaminari** - Paginação
- **Service Workers** - Suporte offline

### Infraestrutura
- **Docker** - Containerização
- **Docker Compose** - Orquestração
- **Kamal** - Deploy

## ✨ Funcionalidades

### Gerenciamento de Alimentos
- ✅ CRUD completo de itens alimentícios
- 📊 Dashboard com visão geral do estoque
- 🔍 Filtros por categoria, local de armazenamento e status
- ⚠️ Alertas visuais para produtos vencidos ou próximos do vencimento
- 📅 Cálculo automático de dias até o vencimento

### Sistema FIFO (First In, First Out)
- 🔄 Rotação automática baseada em data de entrada
- 📋 Sugestões de consumo priorizando produtos mais antigos
- 📈 Relatórios de eficiência de rotação

### Notificações
- 🔔 Notificações push para vencimentos próximos
- ⚙️ Configuração personalizada de alertas
- 📱 Suporte para múltiplos dispositivos

### PWA & Offline
- 📱 Instalável como app nativo
- 🔌 Funciona sem conexão com internet
- 🔄 Sincronização automática quando online

### API REST
- 🌐 API completa para integração
- 📝 Documentação OpenAPI/Swagger
- 🔐 Suporte para autenticação

## 📦 Pré-requisitos

### Desenvolvimento Local
- Ruby 3.4.7
- Rails 8.0.3
- SQLite3

### Desenvolvimento com Docker (Recomendado)
- Docker
- Docker Compose

## 🔧 Instalação

### Opção 1: Usando Docker (Recomendado)

#### Setup Inicial
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/survival_backpack.git
cd survival_backpack

# Execute o setup completo (build + database)
./bin/docker-setup
```

A aplicação estará disponível em: **http://localhost:3000**

#### Comandos Disponíveis

```bash
# Iniciar aplicação
./bin/docker-up

# Parar aplicação
./bin/docker-stop

# Ver logs em tempo real
./bin/docker-logs

# Ver últimas 50 linhas dos logs
./bin/docker-logs -n 50

# Ver todos os logs
./bin/docker-logs --all

# Acessar console Rails
./bin/docker-console

# Limpar cache e logs
./bin/docker-clean-cache

# Limpeza completa (containers, volumes, imagens)
./bin/docker-clean
```

### Opção 2: Instalação Local

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/survival_backpack.git
cd survival_backpack

# Instale as dependências
bundle install

# Configure o banco de dados
rails db:setup

# Inicie o servidor
rails server
```

A aplicação estará disponível em: **http://localhost:3000**

## 🐳 Scripts Docker

O projeto inclui scripts para facilitar o desenvolvimento com Docker:

| Script | Função | Uso |
|--------|--------|-----|
| `docker-setup` | 🔧 Setup inicial completo | `./bin/docker-setup` |
| `docker-up` | 🚀 Iniciar aplicação | `./bin/docker-up` |
| `docker-stop` | 🛑 Parar aplicação | `./bin/docker-stop` |
| `docker-logs` | 📜 Ver logs (com opções) | `./bin/docker-logs [opções]` |
| `docker-test` | 🧪 Executar testes | `./bin/docker-test [opções]` |
| `docker-console` | 💻 Console Rails no container | `./bin/docker-console` |
| `docker-clean-cache` | 🗑️ Limpar cache/logs | `./bin/docker-clean-cache` |
| `docker-clean` | 🧹 Limpeza completa | `./bin/docker-clean` |

### Opções do docker-logs

```bash
# Modo padrão: últimas 100 linhas + seguir logs
./bin/docker-logs

# Mostrar últimas 50 linhas
./bin/docker-logs -n 50

# Mostrar todos os logs
./bin/docker-logs --all

# Não seguir logs (apenas mostrar e sair)
./bin/docker-logs --no-follow

# Ver ajuda
./bin/docker-logs --help
```

### Opções do docker-test

```bash
# Modo padrão: executar todos os testes
./bin/docker-test

# Executar apenas testes de models
./bin/docker-test --models

# Executar apenas testes de controllers
./bin/docker-test --controllers

# Executar testes de integração
./bin/docker-test --integration

# Executar testes de sistema
./bin/docker-test --system

# Executar arquivo específico
./bin/docker-test --file test/models/food_item_test.rb

# Executar com cobertura de código
./bin/docker-test --coverage

# Ver ajuda
./bin/docker-test --help
```

## 📚 Documentação

O projeto possui documentação detalhada na pasta `docs/`:

### Documentação Geral
- 📖 **[API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md)** - Documentação completa da API REST
- 🏗️ **[IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)** - Resumo da implementação

### Features Específicas
- 🍽️ **[FOOD_ITEMS_FEATURE.md](docs/FOOD_ITEMS_FEATURE.md)** - Sistema de gerenciamento de alimentos
- 🔄 **[FIFO_ROTATION_SYSTEM.md](docs/FIFO_ROTATION_SYSTEM.md)** - Sistema de rotação FIFO
- 🔔 **[NOTIFICATIONS_SYSTEM.md](docs/NOTIFICATIONS_SYSTEM.md)** - Sistema de notificações

### Guias Práticos
- ⚡ **[FIFO_QUICKSTART.md](docs/FIFO_QUICKSTART.md)** - Início rápido com FIFO
- 🔔 **[NOTIFICATIONS_QUICKSTART.md](docs/NOTIFICATIONS_QUICKSTART.md)** - Configurar notificações
- 🔌 **[OFFLINE_TESTING_GUIDE.md](docs/OFFLINE_TESTING_GUIDE.md)** - Testar funcionalidades offline (Desenvolvedores)
- 📱 **[USER_INSTALLATION_GUIDE.md](docs/USER_INSTALLATION_GUIDE.md)** - Guia de instalação para usuários finais
- 🐳 **[DOCKER_DEVELOPMENT.md](docs/DOCKER_DEVELOPMENT.md)** - Desenvolvimento com Docker

### Guias de Implementação
- 📋 **[IMPLEMENTATION_NOTIFICATIONS.md](docs/IMPLEMENTATION_NOTIFICATIONS.md)** - Como implementar notificações

## 🧪 Testes

### Executar todos os testes
```bash
# Com Docker (Recomendado)
./bin/docker-test

# Localmente
rails test
```

### Executar testes específicos
```bash
# Com Docker (Recomendado)
./bin/docker-test --models           # Testes de models
./bin/docker-test --controllers      # Testes de controllers
./bin/docker-test --integration      # Testes de integração
./bin/docker-test --system           # Testes de sistema

# Localmente
rails test test/models/
rails test test/controllers/
rails test:system
```

### Executar com cobertura
```bash
# Com Docker
./bin/docker-test --coverage

# Localmente
COVERAGE=true rails test
```

### Cobertura de Testes
O projeto segue TDD (Test-Driven Development) com cobertura de:
- ✅ Models e validações
- ✅ Controllers e ações
- ✅ APIs e endpoints
- ✅ Serviços e jobs
- ✅ Integrações

## 🌐 API

### Base URL
```
http://localhost:3000/api/v1
```

### Endpoints Principais

#### Food Items (Alimentos)
```bash
# Listar alimentos
GET /api/v1/food_items

# Filtrar alimentos
GET /api/v1/food_items?filter=expiring_soon&category=Grãos

# Buscar alimento específico
GET /api/v1/food_items/:id

# Criar alimento
POST /api/v1/food_items

# Atualizar alimento
PATCH /api/v1/food_items/:id

# Deletar alimento
DELETE /api/v1/food_items/:id
```

#### FIFO Rotation
```bash
# Obter sugestões de rotação
GET /api/v1/fifo_rotation/suggestions

# Registrar consumo
POST /api/v1/fifo_rotation/consume
```

#### Notifications
```bash
# Listar notificações
GET /api/v1/notifications

# Registrar subscription push
POST /api/v1/notifications/subscribe

# Configurar notificações
PATCH /api/v1/notification_settings/:id
```

### Autenticação
```bash
# A implementar: JWT ou Token-based authentication
```

Para documentação completa da API, consulte [API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md)

## 📁 Estrutura do Projeto

```
survival_backpack/
├── app/
│   ├── controllers/          # Controllers MVC e API
│   │   └── api/v1/          # API REST v1
│   ├── models/              # Models ActiveRecord
│   ├── views/               # Views Hotwire
│   ├── javascript/          # JavaScript/Stimulus
│   ├── jobs/                # Background jobs
│   └── services/            # Lógica de negócio
│
├── bin/                     # Scripts executáveis
│   ├── docker-*             # Scripts Docker
│   ├── rails                # Rails CLI
│   └── setup                # Setup inicial
│
├── config/                  # Configurações
│   ├── routes.rb           # Rotas
│   └── database.yml        # Database config
│
├── db/                      # Banco de dados
│   ├── migrate/            # Migrations
│   └── seeds.rb            # Seeds
│
├── docs/                    # Documentação
│   ├── API_DOCUMENTATION.md
│   ├── FIFO_*.md
│   └── ...
│
├── test/                    # Testes
│   ├── models/
│   ├── controllers/
│   ├── integration/
│   └── system/
│
├── docker-compose.yml       # Docker Compose config
├── Dockerfile              # Dockerfile production
├── Dockerfile.dev          # Dockerfile development
└── README.md               # Este arquivo
```

## 🛠️ Desenvolvimento

### Executar Console
```bash
# Local
rails console

# Docker
./bin/docker-console
```

### Executar Migrations
```bash
# Local
rails db:migrate

# Docker
./bin/docker-console
rails db:migrate
```

### Gerar Modelo
```bash
rails generate model NomeModelo campo:tipo
```

### Gerar Controller
```bash
rails generate controller NomeController
```

### Code Quality
```bash
# Rubocop (linter)
./bin/rubocop

# Brakeman (security)
./bin/brakeman
```

## 🔐 Segurança

- 🔒 CSRF protection habilitado
- 🛡️ Content Security Policy configurado
- 🔑 Secrets gerenciados via Rails credentials
- 🔐 Brakeman para análise de segurança

## 📈 Performance

- ⚡ Turbo para navegação SPA-like
- 🗜️ Asset pipeline otimizado
- 💾 Cache de queries
- 📦 PWA com cache offline

## 🌍 Deploy

### Desenvolvimento
```bash
./bin/docker-up
```

### Produção com Kamal
```bash
# Configure suas credenciais
kamal setup

# Deploy
kamal deploy
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código
- Seguir convenções Rails
- Escrever testes para novas features
- Documentar mudanças significativas
- Usar Rubocop para style guide

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👥 Autores

- **JML Consult Tech** - *Desenvolvimento inicial*

## 🙏 Agradecimentos

- Ruby on Rails Team
- Hotwire Team
- Comunidade Open Source

## 📞 Suporte

Para suporte e dúvidas:
- 📧 Email: suporte@jmlconsultech.com
- 📱 Issues: [GitHub Issues](https://github.com/seu-usuario/survival_backpack/issues)
- 📖 Documentação: [docs/](docs/)

---

⚡ **Desenvolvido com Rails 8 e Hotwire**

🎒 **Survival Backpack** - Gerencie seus alimentos de forma inteligente
