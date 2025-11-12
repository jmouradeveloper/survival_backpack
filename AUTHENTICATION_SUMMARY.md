# Sistema de Autenticação e Autorização - Resumo

## ✅ Implementação Completa

Este documento resume o sistema de autenticação e autorização implementado no Survival Backpack.

## 🔐 Componentes Implementados

### 1. Modelos

#### User (`app/models/user.rb`)
- ✅ `has_secure_password` do Rails 8
- ✅ Validações de email (formato, unicidade, presença)
- ✅ Validações de senha forte (mínimo 8 caracteres, letras maiúsculas/minúsculas, números, caracteres especiais)
- ✅ Enum de roles: `:user` (padrão) e `:admin`
- ✅ Tracking de `last_login_at` para expiração de sessão
- ✅ Método `session_expired?` verifica sessões com mais de 30 dias
- ✅ Método `update_last_login!` atualiza timestamp de login
- ✅ Método `generate_api_token` para criar tokens de API
- ✅ Associações com todos os recursos (food_items, supply_batches, etc.)
- ✅ Criação automática de NotificationPreference

#### ApiToken (`app/models/api_token.rb`)
- ✅ Geração automática de tokens seguros usando `SecureRandom.base58`
- ✅ Hashing de tokens com SHA256 antes de armazenar
- ✅ Atributo virtual `raw_token` (visível apenas na criação)
- ✅ Validação de unicidade do token_digest
- ✅ Expiração padrão de 90 dias
- ✅ Scopes: `active`, `expired`, `recently_used`
- ✅ Método `find_by_token` para autenticar via token
- ✅ Métodos `mark_as_used!` e `revoke!`

#### Current (`app/models/current.rb`)
- ✅ Thread-safe storage do usuário atual usando `ActiveSupport::CurrentAttributes`

### 2. Controllers e Concerns

#### Authentication Concern (`app/controllers/concerns/authentication.rb`)
- ✅ `authenticate_user!` - força autenticação
- ✅ `current_user` - retorna usuário autenticado
- ✅ `user_signed_in?` - verifica se há usuário logado
- ✅ `check_session_expiration` - valida expiração de 30 dias
- ✅ `login(user)` - inicia sessão e atualiza last_login_at
- ✅ `logout` - encerra sessão

#### Authorization Concern (`app/controllers/concerns/authorization.rb`)
- ✅ `authorize_admin!` - restringe acesso a admins
- ✅ `authorize_owner!` - verifica propriedade do recurso
- ✅ Tratamento de erros com `NotAuthorizedError`

#### Web Controllers
- ✅ `SessionsController` - login/logout via web
- ✅ `RegistrationsController` - cadastro de novos usuários
- ✅ `ApiTokensController` - gerenciamento de tokens via web

#### API Controllers
- ✅ `Api::V1::SessionsController` - login via API retorna token
- ✅ `Api::V1::ApiTokensController` - CRUD de tokens via API
- ✅ `Api::V1::BaseController` - autenticação via Bearer token
- ✅ Todos os controllers de API atualizados para usar `current_user`

### 3. Autenticação Híbrida

#### Autenticação Web (Session-based)
- ✅ Cookie seguro com httponly, secure (production), same_site: :lax
- ✅ Expiração automática após 30 dias
- ✅ Session store configurado em `config/initializers/session_store.rb`

#### Autenticação API (Token-based)
- ✅ Header: `Authorization: Bearer <token>`
- ✅ Validação de token expirado
- ✅ Atualização automática de `last_used_at`
- ✅ Suporte a múltiplos tokens por usuário

### 4. Segurança

✅ **Senhas Fortes**
- Mínimo 8 caracteres
- Letras maiúsculas e minúsculas
- Números
- Caracteres especiais

✅ **Proteção de Sessão**
- Expiração automática após 30 dias de inatividade
- Cookies seguros (httponly, secure em production)
- CSRF protection ativada

✅ **Tokens de API**
- Tokens hasheados antes de armazenar no banco
- Token raw visível apenas uma vez na criação
- Expiração configurável
- Possibilidade de revogação

✅ **Isolamento de Dados**
- Cada usuário só acessa seus próprios dados
- Todos os recursos associados a `user_id`
- Scopes automáticos por `current_user`

### 5. Migrations

✅ **Users Table**
```sql
- email (string, unique, not null)
- password_digest (string, not null)
- role (integer, default: 0, not null)
- last_login_at (datetime)
- timestamps
```

✅ **API Tokens Table**
```sql
- user_id (references, not null)
- token_digest (string, unique, not null)
- name (string)
- last_used_at (datetime)
- expires_at (datetime)
- timestamps
```

✅ **User Associations**
- user_id adicionado a todas as tabelas existentes:
  - food_items
  - supply_batches
  - supply_rotations
  - notifications
  - notification_preferences

### 6. Rotas

#### Web Routes
```ruby
get  "login"  => "sessions#new"
post "login"  => "sessions#create"
delete "logout" => "sessions#destroy"

get  "signup" => "registrations#new"
post "signup" => "registrations#create"

resources :api_tokens, only: [:index, :create, :destroy]
```

#### API Routes
```ruby
namespace :api do
  namespace :v1 do
    post   "login"  => "sessions#create"
    delete "logout" => "sessions#destroy"
    resources :api_tokens, only: [:index, :create, :destroy]
    
    # Todos os recursos protegidos por autenticação
  end
end
```

### 7. Views (Hotwire-ready)

✅ **Login** (`app/views/sessions/new.html.erb`)
- Formulário responsivo com Turbo
- Design moderno com Tailwind CSS
- Link para cadastro

✅ **Cadastro** (`app/views/registrations/new.html.erb`)
- Validação de senha com requisitos visíveis
- Confirmação de senha
- Mensagens de erro contextuais

### 8. Testes Automatizados

✅ **Model Tests**
- `test/models/user_test.rb` - 14 testes
  - Validações de email e senha
  - Autenticação
  - Roles e permissões
  - Expiração de sessão
  - Geração de tokens
- `test/models/api_token_test.rb` - 10 testes
  - Geração de tokens
  - Validações
  - Expiração
  - Revogação
  - Hashing

✅ **Controller Tests**
- `test/controllers/sessions_controller_test.rb` - 7 testes
- `test/controllers/registrations_controller_test.rb` - 5 testes

## 🚀 Como Usar

### Usuário Padrão (Migração)

Se houver dados existentes, um usuário admin padrão foi criado:
```
Email: admin@example.com
Senha: Admin@123
```

**⚠️ IMPORTANTE: Altere esta senha imediatamente após o primeiro login!**

### Web Authentication

1. **Login**: Acesse `/login`
2. **Cadastro**: Acesse `/signup`
3. **Logout**: Clique no botão de logout (DELETE `/logout`)

### API Authentication

1. **Obter Token**:
```bash
POST /api/v1/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123!",
  "token_name": "My API Token"
}

Response:
{
  "token": "xxxxxxxxxxx",
  "user": {...},
  "expires_at": "2025-02-11T..."
}
```

2. **Usar Token**:
```bash
GET /api/v1/food_items
Authorization: Bearer xxxxxxxxxxx
```

3. **Revogar Token**:
```bash
DELETE /api/v1/logout
Authorization: Bearer xxxxxxxxxxx
```

### Gerenciar Tokens via Web

Acesse `/api_tokens` para:
- Visualizar todos os seus tokens
- Criar novos tokens
- Revogar tokens existentes
- Ver último uso e expiração

## 🔒 Níveis de Autorização

### User (Padrão)
- Acessa apenas seus próprios recursos
- CRUD completo em seus dados
- Não pode acessar dados de outros usuários

### Admin
- Acessa todos os recursos
- Pode ver dados de todos os usuários
- Acesso a operações administrativas

## 📝 Notas de Implementação

1. **Dados Existentes**: A migração associou todos os dados existentes ao usuário admin padrão
2. **Hotwire**: Todas as views usam Turbo para navegação SPA-like
3. **Offline**: O sistema funciona offline após autenticação inicial
4. **Docker**: Use `bin/docker-test` para executar os testes

## 🧪 Executar Testes

```bash
# Todos os testes
bin/docker-test

# Apenas testes de models
bin/docker-test --models

# Apenas testes de autenticação
bin/docker-test --file test/models/user_test.rb
bin/docker-test --file test/models/api_token_test.rb
bin/docker-test --file test/controllers/sessions_controller_test.rb
```

## ✨ Próximos Passos Recomendados

1. Alterar senha do usuário admin padrão
2. Criar usuários adicionais conforme necessário
3. Testar o fluxo de autenticação web e API
4. Personalizar as views de login/registro conforme design do projeto
5. Configurar rate limiting para proteção contra brute force (opcional)
6. Implementar recuperação de senha (opcional)
7. Adicionar 2FA (opcional)

---

**Sistema implementado com sucesso! ✅**

Todas as funcionalidades de autenticação e autorização estão operacionais e testadas.

