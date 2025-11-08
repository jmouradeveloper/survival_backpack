# Sistema de Notificações e Alertas - Survival Backpack

## 📋 Visão Geral

Este documento descreve o sistema completo de notificações e alertas implementado no Survival Backpack, que utiliza a API de notificações nativa do Rails 8 e suporta push notifications mesmo em modo offline.

## ✨ Funcionalidades Implementadas

### 1. **Sistema de Notificações Baseado no Rails 8**
- Modelo `Notification` para armazenar todas as notificações
- Modelo `NotificationPreference` para configurações do usuário
- API completa (REST) para gerenciamento de notificações
- Interface web com Hotwire/Turbo para atualização em tempo real

### 2. **Alertas Automáticos de Validade**
- Job recorrente (`ExpirationNotificationJob`) que verifica validades
- Notificações automáticas quando alimentos estão próximos do vencimento
- Três níveis de prioridade:
  - 🔴 Alta: vencimento hoje ou amanhã
  - 🟡 Média: vencimento em 2-3 dias
  - 🔵 Baixa: vencimento dentro do prazo configurado

### 3. **Configuração de Tempo Antecipado**
- Interface para configurar quantos dias antes ser notificado (padrão: 7 dias)
- Configurações individuais para push notifications e email
- Possibilidade de testar notificações

### 4. **Push Notifications Offline**
- Service Worker aprimorado com suporte completo a push notifications
- IndexedDB para armazenar notificações offline
- Background Sync para sincronizar quando voltar online
- Periodic Background Sync para verificar validades mesmo offline (24h)

## 🏗️ Arquitetura

### Modelos de Dados

#### Notification
```ruby
# Campos principais:
- food_item_id: referência ao alimento
- title: título da notificação
- body: corpo da mensagem
- notification_type: tipo (expiration_warning, expiration_urgent, expired)
- read: boolean (lida/não lida)
- priority: 0 (baixa), 1 (média), 2 (alta)
- sent_at: quando foi enviada
- scheduled_for: agendamento
```

#### NotificationPreference
```ruby
# Campos principais:
- days_before_expiration: dias de antecedência (padrão: 7)
- enable_push_notifications: ativar push (padrão: true)
- enable_email_notifications: ativar email (padrão: false)
- push_subscription_endpoint: endpoint da subscription
- push_subscription_keys: chaves de criptografia (JSON)
- last_checked_at: última verificação
```

### Jobs

#### ExpirationNotificationJob
Job recorrente configurado em `config/recurring.yml`:
- **Development**: executa a cada hora
- **Production**: executa a cada 6 horas

Responsabilidades:
1. Buscar alimentos próximos do vencimento
2. Criar notificações apropriadas
3. Evitar duplicatas (não criar se já existe uma nas últimas 24h)
4. Enviar push notifications se habilitadas

### Controllers

#### Web (Hotwire)
- `NotificationsController`: gerencia visualização e interação com notificações
- `NotificationPreferencesController`: gerencia configurações

#### API (REST)
- `Api::V1::NotificationsController`: CRUD completo de notificações
- `Api::V1::NotificationPreferencesController`: gerenciamento de preferências

### Service Worker

O Service Worker (`app/views/pwa/service-worker.js`) implementa:

1. **Push Notifications**:
   - Recebe e exibe notificações via `push` event
   - Armazena em IndexedDB para acesso offline
   - Click handler para navegar para conteúdo relacionado

2. **Background Sync**:
   - Sincroniza dados quando voltar online
   - Tags suportadas: `sync-food-items`, `sync-notifications`, `check-expirations`

3. **Periodic Background Sync**:
   - Verifica validades a cada 24 horas (mesmo offline)
   - Utiliza dados em cache para criar notificações

4. **IndexedDB**:
   - Database: `notifications-db`
   - Store: `notifications`
   - Índices: timestamp, foodItemId

### Frontend (Stimulus)

#### NotificationsController
Stimulus controller que gerencia:
- Solicitação de permissões de notificação
- Registro de Service Worker
- Subscription para push notifications
- Polling de contador de não lidas (1 minuto)
- Ações: marcar como lida, marcar todas como lidas
- Badge de contador no menu

## 🔌 API Endpoints

### Notificações

```
GET    /api/v1/notifications                    # Listar (com filtros e paginação)
GET    /api/v1/notifications/:id                # Ver detalhes
POST   /api/v1/notifications/:id/mark_as_read   # Marcar como lida
POST   /api/v1/notifications/mark_all_as_read   # Marcar todas como lidas
DELETE /api/v1/notifications/:id                # Remover
GET    /api/v1/notifications/unread_count       # Contador de não lidas
```

#### Filtros disponíveis:
- `unread=true`: apenas não lidas
- `type=expiration_warning`: por tipo
- `page=1&per_page=20`: paginação

### Preferências

```
GET    /api/v1/notification_preferences         # Ver configurações
PATCH  /api/v1/notification_preferences         # Atualizar
POST   /api/v1/notification_preferences/subscribe_push    # Registrar push
DELETE /api/v1/notification_preferences/unsubscribe_push  # Cancelar push
```

## 🚀 Como Usar

### 1. Ativar Notificações

1. Acesse a página principal
2. Clique no botão "Ativar Notificações" (se aparecer)
3. Conceda permissão no navegador
4. As push notifications serão configuradas automaticamente

### 2. Configurar Preferências

1. Acesse "⚙️ Configurações" no menu
2. Defina quantos dias antes deseja ser notificado
3. Ative/desative push notifications e email
4. Clique em "💾 Salvar Configurações"
5. Use "🧪 Testar Notificação" para verificar funcionamento

### 3. Visualizar Notificações

1. Acesse "🔔 Notificações" no menu
2. O badge mostra quantas não lidas você tem
3. Clique em uma notificação para ver detalhes
4. Use "Marcar todas como lidas" para limpar

### 4. Forçar Verificação Manual

Na página de configurações, clique em "🔄 Verificar Validades Agora" para:
- Executar o job imediatamente
- Criar notificações para alimentos próximos do vencimento
- Receber notificação de teste

## 📱 Modo Offline

### Funcionalidades Offline:

1. **Verificação de Validades**:
   - Usa dados em cache do IndexedDB
   - Executa periodicamente (se Periodic Sync disponível)
   - Cria e exibe notificações localmente

2. **Visualização de Notificações**:
   - Notificações armazenadas são acessíveis offline
   - Interface funciona via cache do Service Worker

3. **Sincronização Automática**:
   - Ao voltar online, sincroniza automaticamente
   - Marca notificações como lidas no servidor
   - Atualiza dados em cache

### Testando Offline:

1. Abra o DevTools (F12)
2. Vá para a aba "Application" > "Service Workers"
3. Marque "Offline"
4. Navegue pela aplicação normalmente
5. Notificações continuarão funcionando!

## 🔧 Configuração Técnica

### Recurring Jobs

Arquivo: `config/recurring.yml`

```yaml
development:
  check_food_expiration:
    class: ExpirationNotificationJob
    schedule: every hour

production:
  check_food_expiration:
    class: ExpirationNotificationJob
    schedule: every 6 hours
```

### Service Worker Cache

Nome do cache: `survival-backpack-v2`

Assets essenciais:
- `/` (página inicial)
- `/food_items` (lista de alimentos)
- `/notifications` (lista de notificações)
- `/notification_preferences` (configurações)
- Assets CSS e JS

### Push Notifications (Web Push API)

Para habilitar push notifications em produção:

1. Gerar VAPID keys:
```bash
docker compose exec web bin/rails credentials:edit
```

2. Adicionar ao credentials:
```yaml
vapid:
  public_key: YOUR_PUBLIC_KEY
  private_key: YOUR_PRIVATE_KEY
```

3. Adicionar meta tag no layout:
```erb
<meta name="vapid-public-key" content="<%= Rails.application.credentials.dig(:vapid, :public_key) %>">
```

4. Instalar gem web-push (se necessário):
```ruby
gem 'web-push'
```

## 🧪 Testes

### Testar no Docker:

```bash
# Executar job manualmente
docker compose exec web bin/rails runner "ExpirationNotificationJob.perform_now"

# Console Rails
docker compose exec web bin/rails console

# No console:
# Criar preferência padrão
NotificationPreference.create!(days_before_expiration: 7)

# Criar notificação de teste
food = FoodItem.first
Notification.create!(
  food_item: food,
  title: "Teste",
  body: "Notificação de teste",
  notification_type: "expiration_warning",
  priority: 1
)

# Ver contador de não lidas
Notification.unread.count
```

### Testar Push Notifications:

1. Acesse as configurações
2. Clique em "🧪 Testar Notificação"
3. Deve aparecer uma notificação do sistema

## 📊 Estatísticas

Para obter estatísticas de notificações:

```ruby
# Total de notificações
Notification.count

# Não lidas
Notification.unread.count

# Por tipo
Notification.group(:notification_type).count

# Por prioridade
Notification.group(:priority).count

# Últimas 24 horas
Notification.where('created_at > ?', 24.hours.ago).count
```

## 🔐 Segurança

- CSRF tokens em todas as requisições POST/DELETE
- Validações de dados nos modelos
- Sanitização de conteúdo nas views
- Push subscription keys armazenadas de forma segura
- Service Worker com scope limitado

## 🐛 Troubleshooting

### Notificações não aparecem

1. Verificar permissão do navegador
2. Verificar se Service Worker está registrado
3. Ver logs do job: `docker compose logs web`
4. Verificar preferências estão ativas

### Push notifications offline não funcionam

1. Verificar se browser suporta Periodic Background Sync
2. Verificar se há dados em cache
3. Abrir DevTools > Application > IndexedDB > notifications-db
4. Verificar logs do Service Worker

### Job não está executando

1. Verificar `config/recurring.yml`
2. Ver logs: `docker compose exec web bin/rails solid_queue:status`
3. Executar manualmente para testar

## 📚 Recursos Adicionais

- [Rails Guides - Active Job](https://guides.rubyonrails.org/active_job_basics.html)
- [MDN - Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API)
- [MDN - Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Hotwire Documentation](https://hotwired.dev/)
- [Stimulus Reference](https://stimulus.hotwired.dev/reference)

## 🎉 Conclusão

O sistema de notificações está completamente funcional e pronto para uso! Ele oferece:

✅ Notificações automáticas de validade
✅ Configuração flexível pelo usuário
✅ Funcionamento offline completo
✅ API REST completa
✅ Interface moderna com Hotwire
✅ Push notifications nativas
✅ Sincronização automática

Agora os usuários nunca mais perderão alimentos vencidos! 🎒📅

