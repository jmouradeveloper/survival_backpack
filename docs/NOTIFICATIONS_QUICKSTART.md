# 🔔 Sistema de Notificações - Guia Rápido

## 🚀 Como Começar

### 1. Executar o Script de Teste

Para criar dados de demonstração e testar o sistema:

```bash
./test_notifications.sh
```

Este script irá:
- Criar preferências padrão
- Adicionar alimentos de teste com diferentes validades
- Executar o job de verificação
- Mostrar estatísticas de notificações criadas

### 2. Acessar a Aplicação

Abra seu navegador em: **http://localhost:3000**

### 3. Ativar Notificações Push

1. Ao carregar a página, você verá um banner solicitando permissão
2. Clique em "Ativar Notificações"
3. Conceda permissão quando o navegador solicitar
4. Você receberá uma notificação de confirmação

### 4. Explorar as Funcionalidades

#### Menu Principal:
- **🍞 Alimentos**: Visualizar e gerenciar alimentos
- **🔔 Notificações**: Ver todas as notificações (badge mostra contador)
- **⚙️ Configurações**: Ajustar preferências de notificação

#### Página de Notificações:
- Lista todas as notificações com prioridades visuais
- Botões para marcar como lida ou remover
- Link direto para o alimento relacionado
- Contador de não lidas no topo

#### Página de Configurações:
- Ajustar quantos dias antes ser notificado (padrão: 7)
- Ativar/desativar push notifications
- Ativar/desativar notificações por email (futuro)
- Testar notificações
- Ver status do sistema

## 🧪 Testando Offline

### Chrome/Edge:
1. Abra DevTools (F12)
2. Vá para "Application" > "Service Workers"
3. Marque a opção "Offline"
4. Navegue pela aplicação - tudo continuará funcionando!

### Firefox:
1. Abra DevTools (F12)
2. Vá para "Network"
3. Selecione "Offline" no dropdown de throttling

### Teste a funcionalidade:
- As notificações existentes estarão acessíveis
- O Service Worker continuará verificando validades
- Novas notificações serão criadas localmente
- Ao voltar online, tudo sincroniza automaticamente

## 📝 Comandos Úteis

### Executar Job Manualmente
```bash
docker compose exec web bin/rails runner "ExpirationNotificationJob.perform_now"
```

### Ver Estatísticas
```bash
docker compose exec web bin/rails console
# No console:
Notification.count          # Total
Notification.unread.count   # Não lidas
Notification.group(:priority).count  # Por prioridade
```

### Limpar Notificações
```bash
docker compose exec web bin/rails runner "Notification.destroy_all"
```

### Resetar Preferências
```bash
docker compose exec web bin/rails runner "NotificationPreference.destroy_all"
```

## 🔍 Verificar Logs

### Ver logs do container:
```bash
docker compose logs -f web
```

### Ver logs do Solid Queue (jobs):
```bash
docker compose exec web bin/rails solid_queue:status
```

## 🎯 Cenários de Teste

### Cenário 1: Alimento Vencendo Hoje
1. Cadastre um alimento com validade para hoje
2. Execute o job manualmente
3. Veja a notificação urgente (🔴) aparecer

### Cenário 2: Mudar Dias de Antecedência
1. Vá em Configurações
2. Mude de 7 para 14 dias
3. Salve
4. Execute o job novamente
5. Veja mais notificações aparecerem

### Cenário 3: Push Notification Offline
1. Cadastre alguns alimentos
2. Carregue a aplicação
3. Ative modo offline no DevTools
4. O Service Worker continuará monitorando
5. Você receberá notificações mesmo offline!

## 🐛 Resolução de Problemas

### Notificações não aparecem?
- Verifique se concedeu permissão no navegador
- Veja se o Service Worker está ativo (DevTools > Application)
- Execute o job manualmente para testar

### Badge não atualiza?
- O polling acontece a cada 60 segundos
- Recarregue a página para forçar atualização
- Verifique o console do navegador por erros

### Job não está executando?
- Verifique `config/recurring.yml`
- Veja logs: `docker compose logs web | grep ExpirationNotificationJob`
- Execute manualmente para testar

## 📚 Documentação Completa

Veja `NOTIFICATIONS_SYSTEM.md` para:
- Arquitetura detalhada
- API endpoints
- Estrutura de dados
- Configurações avançadas
- Troubleshooting completo

## ✅ Checklist de Funcionalidades

- [x] Notificações automáticas de validade
- [x] Configuração de dias de antecedência
- [x] Push notifications do navegador
- [x] Funcionamento offline completo
- [x] Badge de contador no menu
- [x] Interface para gerenciar notificações
- [x] API REST completa
- [x] Diferentes níveis de prioridade
- [x] Sincronização automática
- [x] Background sync
- [x] Periodic background sync (onde suportado)
- [x] IndexedDB para storage offline

## 🎉 Pronto!

Agora você tem um sistema completo de notificações que:
- ✅ Alerta sobre validades
- ✅ Funciona offline
- ✅ É configurável
- ✅ Usa tecnologias modernas (PWA, Service Workers, Hotwire)
- ✅ Segue os padrões do Rails 8

**Nunca mais perca um alimento vencido! 🎒📅**

