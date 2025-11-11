# 🎒 Survival Backpack - Sistema de Gerenciamento de Estoque

Sistema web de gerenciamento de estoque de suprimentos para situações de emergência, desenvolvido com Ruby on Rails 8 e Hotwire.

## 📋 Funcionalidades Implementadas

### ✅ Cadastro de Alimentos

Sistema completo de gerenciamento de alimentos com as seguintes características:

- **Cadastro completo** com informações detalhadas:
  - Nome do alimento
  - Categoria (Grãos, Enlatados, Conservas, Desidratados, etc.)
  - Quantidade disponível
  - Data de validade
  - Local de armazenamento (Despensa, Geladeira, Freezer, etc.)
  - Observações adicionais

- **Funcionalidades de Gerenciamento**:
  - Listagem de todos os alimentos cadastrados
  - Filtros por categoria, local de armazenamento e status
  - Edição de informações
  - Remoção de itens
  - Cards visuais com status colorido (Válido, Vencendo em Breve, Vencido)

- **Interface Moderna com Hotwire**:
  - Turbo Frames para navegação rápida sem recarregar a página
  - Turbo Streams para atualizações em tempo real
  - Modal dinâmico para formulários
  - Animações suaves com Stimulus
  - Filtros com submissão automática

- **API RESTful Completa**:
  - Endpoints para CRUD completo
  - Paginação e filtros
  - Estatísticas do estoque
  - Respostas JSON padronizadas
  - Documentação detalhada em `API_DOCUMENTATION.md`

- **Suporte Offline**:
  - Service Worker configurado
  - Cache de assets essenciais
  - Estratégia Network First com fallback para cache
  - Sincronização em background (preparado para IndexedDB)

## 🚀 Como Executar

Este projeto roda exclusivamente via Docker Compose:

### 1. Iniciar o servidor

```bash
docker compose up
```

### 2. Acessar a aplicação

- **Interface Web**: http://localhost:3000
- **API**: http://localhost:3000/api/v1

### 3. Popular com dados de exemplo

```bash
docker compose exec web bin/rails db:seed
```

## 📁 Estrutura do Projeto

```
app/
├── controllers/
│   ├── food_items_controller.rb          # Controller web
│   └── api/
│       └── v1/
│           ├── base_controller.rb         # Controller base da API
│           └── food_items_controller.rb   # Controller API de alimentos
├── models/
│   └── food_item.rb                       # Modelo com validações e scopes
├── views/
│   ├── food_items/
│   │   ├── index.html.erb                 # Lista de alimentos
│   │   ├── new.html.erb                   # Modal de novo alimento
│   │   ├── edit.html.erb                  # Modal de edição
│   │   ├── _form.html.erb                 # Formulário reutilizável
│   │   ├── _food_item.html.erb            # Card de alimento
│   │   ├── create.turbo_stream.erb        # Resposta Turbo Stream
│   │   ├── update.turbo_stream.erb        # Resposta Turbo Stream
│   │   ├── destroy.turbo_stream.erb       # Resposta Turbo Stream
│   │   └── form_update.turbo_stream.erb   # Resposta de erro
│   └── layouts/
│       └── application.html.erb           # Layout principal
├── javascript/
│   └── controllers/
│       ├── modal_controller.js            # Controle de modais
│       ├── auto_dismiss_controller.js     # Auto-dismiss de alertas
│       ├── filters_controller.js          # Filtros automáticos
│       └── food_item_controller.js        # Animações de cards
└── assets/
    └── stylesheets/
        └── application.css                # Estilos modernos e responsivos
```

## 🎨 Interface Visual

A interface foi desenvolvida seguindo princípios de UX modernos:

- **Design System Consistente**:
  - Paleta de cores profissional
  - Tipografia clara e legível
  - Espaçamento harmonioso
  - Sombras suaves para profundidade

- **Responsividade**:
  - Grid adaptável para diferentes tamanhos de tela
  - Mobile-first approach
  - Cards que se reorganizam automaticamente

- **Feedback Visual**:
  - Status coloridos (Verde: válido, Amarelo: vencendo, Vermelho: vencido)
  - Animações suaves de entrada/saída
  - Alertas com auto-dismiss
  - Loading states (via Turbo)

## 🔌 API

A API foi desenvolvida seguindo padrões RESTful:

### Endpoints Principais

- `GET /api/v1/food_items` - Listar alimentos (com filtros e paginação)
- `GET /api/v1/food_items/:id` - Buscar alimento específico
- `POST /api/v1/food_items` - Criar novo alimento
- `PATCH /api/v1/food_items/:id` - Atualizar alimento
- `DELETE /api/v1/food_items/:id` - Remover alimento
- `GET /api/v1/food_items/statistics` - Estatísticas do estoque

### Exemplo de Uso

```bash
# Listar alimentos vencendo em breve
curl http://localhost:3000/api/v1/food_items?filter=expiring_soon

# Criar novo alimento
curl -X POST http://localhost:3000/api/v1/food_items \
  -H "Content-Type: application/json" \
  -d '{
    "food_item": {
      "name": "Arroz",
      "category": "Grãos",
      "quantity": 5,
      "expiration_date": "2025-12-31",
      "storage_location": "Despensa"
    }
  }'

# Estatísticas
curl http://localhost:3000/api/v1/food_items/statistics
```

Documentação completa: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## 🔧 Tecnologias Utilizadas

- **Ruby on Rails 8.0.3** - Framework backend
- **Hotwire (Turbo + Stimulus)** - Framework frontend
- **SQLite3** - Banco de dados
- **Docker & Docker Compose** - Containerização
- **Service Worker** - Suporte offline
- **CSS3** - Estilização moderna

## 📊 Modelo de Dados

### FoodItem

| Campo | Tipo | Descrição |
|-------|------|-----------|
| name | string | Nome do alimento (obrigatório) |
| category | string | Categoria (obrigatório) |
| quantity | decimal | Quantidade disponível (obrigatório, ≥ 0) |
| expiration_date | date | Data de validade (opcional) |
| storage_location | string | Local de armazenamento (opcional) |
| notes | text | Observações (opcional) |
| created_at | datetime | Data de criação |
| updated_at | datetime | Data de atualização |

### Validações

- Nome: mínimo 2 caracteres, máximo 255
- Categoria: obrigatória
- Quantidade: maior ou igual a zero
- Data de validade: deve ser maior que hoje (se informada)
- Notas: máximo 5000 caracteres

### Scopes Úteis

```ruby
FoodItem.recent                    # Ordenados por mais recentes
FoodItem.by_category("Grãos")      # Filtrar por categoria
FoodItem.expiring_soon             # Vencendo em 7 dias
FoodItem.expired                   # Já vencidos
FoodItem.valid_items               # Válidos
```

## 🎯 Próximas Funcionalidades

- [ ] Autenticação de usuários
- [ ] Alertas de vencimento por email/notificação
- [ ] Histórico de consumo
- [ ] Gráficos e dashboards
- [ ] Impressão de relatórios
- [ ] Integração com código de barras
- [ ] Sugestões de receitas baseadas no estoque
- [ ] Sincronização offline completa com IndexedDB

## 📝 Desenvolvimento

### Comandos Úteis

```bash
# Criar migration
docker compose exec web bin/rails generate migration NomeDaMigration

# Rodar migrations
docker compose exec web bin/rails db:migrate

# Abrir console
docker compose exec web bin/rails console

# Rodar testes
docker compose exec web bin/rails test

# Verificar rotas
docker compose exec web bin/rails routes

# Seed do banco
docker compose exec web bin/rails db:seed
```

### Estrutura de Commits

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `style:` Formatação
- `refactor:` Refatoração
- `test:` Testes
- `chore:` Manutenção

## 📄 Licença

Este projeto foi desenvolvido como parte do sistema Survival Backpack para gerenciamento de suprimentos de emergência.

---

**Desenvolvido com ❤️ usando Ruby on Rails e Hotwire**

