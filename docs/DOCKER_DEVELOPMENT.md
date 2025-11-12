# Arquivo README com instruções de desenvolvimento

## 🚀 Executando a Aplicação em Modo Desenvolvimento

Esta aplicação Ruby on Rails está configurada para rodar com Docker Compose V2.

### Pré-requisitos

- Docker (versão 20.10+ com suporte a `docker compose`)

### Comandos Básicos

#### Iniciar a aplicação

```bash
docker compose up
```

Ou em modo detached (background):

```bash
docker compose up -d
```

A aplicação estará disponível em: http://localhost:3000

#### Parar a aplicação

```bash
docker compose down
```

#### Reconstruir os containers (quando houver mudanças no Dockerfile ou Gemfile)

```bash
docker compose up --build
```

#### Ver logs

```bash
docker compose logs -f web
```

#### Executar comandos Rails

```bash
# Acessar o console Rails
docker compose exec web bin/rails console

# Executar migrations
docker compose exec web bin/rails db:migrate

# Criar um novo model
docker compose exec web bin/rails generate model NomeDoModel

# Executar testes
docker compose exec web bin/rails test

# Acessar o bash do container
docker compose exec web bash
```

#### Instalar novas gems

Após adicionar uma gem no `Gemfile`:

```bash
docker compose exec web bundle install
# ou reconstruir o container
docker compose up --build
```

#### Limpar volumes e dados

```bash
# Remover todos os containers, redes e volumes
docker compose down -v

# Remover apenas os volumes de dados
docker volume rm survival_backpack_bundle_data survival_backpack_node_modules
```

### Estrutura dos Arquivos Docker

- `Dockerfile` - Dockerfile de produção (original do Rails)
- `Dockerfile.dev` - Dockerfile otimizado para desenvolvimento
- `docker-compose.yml` - Orquestração dos serviços de desenvolvimento
- `.dockerignore` - Arquivos ignorados durante o build

### Recursos do Ambiente de Desenvolvimento

- ✅ Hot reload - mudanças no código são refletidas automaticamente
- ✅ Persistência de dados - banco SQLite e volumes persistem entre restarts
- ✅ Cache de gems - gems instaladas ficam em cache
- ✅ Logs acessíveis - logs salvos no diretório `./log`
- ✅ Healthcheck - verifica se a aplicação está funcionando

### Troubleshooting

**Erro de permissões:**
```bash
sudo chown -R $USER:$USER .
```

**Banco de dados corrompido:**
```bash
docker compose exec web bin/rails db:reset
```

**Container não inicia:**
```bash
docker compose logs web
```

**Limpar tudo e começar do zero:**
```bash
docker compose down -v
rm -rf storage/*.sqlite3 tmp/cache/*
docker compose up --build
```

