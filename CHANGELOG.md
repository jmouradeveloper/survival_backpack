# 📝 Changelog - Features

Registro de todas as **features** (novos comportamentos) implementadas no **Survival Backpack**.  
Este changelog documenta apenas funcionalidades novas, não incluindo fixes ou refatorações.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [Não Lançado]

### Em Desenvolvimento
- Sistema de relatórios avançados
- Integração com scanner de código de barras
- Sistema de compartilhamento de listas

---

## [1.4.0] - 2025-11-12

### ✨ Sistema de Backup e Restauração

#### Export/Import de Dados
- **Exportação completa de dados**
  - Exporta todos os alimentos, lotes, rotações e preferências
  - Formato JSON estruturado
  - Inclui metadados de exportação (versão, timestamp)
  - Download direto via navegador

- **Importação de dados**
  - Upload de arquivos de backup (.json)
  - Validação de estrutura e integridade
  - Merge inteligente de dados (evita duplicatas)
  - Relatório de importação (sucessos/erros)
  - Suporte para rollback em caso de erro

- **Interface de Gerenciamento**
  - Página dedicada para backups (`/backups`)
  - Formulário de upload com preview
  - Indicadores visuais de progresso
  - Mensagens de feedback detalhadas

#### API REST
- `GET /api/v1/backups/export` - Exportar dados
- `POST /api/v1/backups/import` - Importar dados

---

## [1.3.0] - 2025-11-09

### ✨ Sistema FIFO (First In, First Out)

#### Gerenciamento de Lotes
- **Supply Batches (Lotes de Suprimentos)**
  - Criação de lotes com múltiplas unidades
  - Controle de quantidade disponível por lote
  - Rastreamento de data de entrada
  - Associação com food items
  - Status automático (disponível, parcialmente consumido, esgotado)

- **Supply Rotations (Rotações de Consumo)**
  - Registro de consumo baseado em FIFO
  - Histórico completo de rotações
  - Rastreamento de quantidade consumida por operação
  - Timestamp de cada rotação
  - Sugestões inteligentes de consumo

#### Lógica FIFO
- **Rotação Automática**
  - Priorização de lotes mais antigos
  - Consumo parcial de lotes
  - Atualização automática de status
  - Marcação de alimento como "a vencer" quando lote próximo expira

- **Sugestões de Consumo**
  - Lista ordenada por prioridade FIFO
  - Informações de quantidade disponível
  - Alertas de vencimento próximo
  - Cálculo de dias até vencimento

#### Interface Web
- **Página de Lotes** (`/supply_batches`)
  - Listagem de todos os lotes
  - Filtros por status e alimento
  - Criação e edição de lotes
  - Visualização de quantidade disponível

- **Página de Rotações** (`/supply_rotations`)
  - Histórico de consumos
  - Informações de lote e alimento
  - Timestamp de cada rotação

- **Dashboard FIFO**
  - Sugestões de consumo em destaque
  - Próximos vencimentos
  - Indicadores visuais de prioridade

#### API REST
- `GET /api/v1/supply_batches` - Listar lotes
- `POST /api/v1/supply_batches` - Criar lote
- `GET /api/v1/supply_batches/:id` - Detalhes do lote
- `PATCH /api/v1/supply_batches/:id` - Atualizar lote
- `DELETE /api/v1/supply_batches/:id` - Remover lote
- `GET /api/v1/fifo_rotation/suggestions` - Sugestões FIFO
- `POST /api/v1/fifo_rotation/consume` - Registrar consumo

---

## [1.2.0] - 2025-11-08

### ✨ Sistema de Notificações Push

#### Web Push Notifications
- **Notificações no Navegador**
  - Push notifications nativas do navegador
  - Funcionamento em background
  - Suporte offline (notificações enfileiradas)
  - Ícone e badge personalizados
  - Sons e vibração configuráveis

- **Configuração VAPID**
  - Chaves VAPID geradas automaticamente
  - Configuração via Rails credentials
  - Suporte para múltiplos ambientes

#### Gerenciamento de Notificações
- **Notification Model**
  - Tipos: `expiring_soon`, `expired`, `fifo_suggestion`
  - Prioridade (low, medium, high)
  - Status (pending, sent, read)
  - Associação com food items
  - Timestamp de envio e leitura

- **Notification Preferences (Preferências)**
  - Configuração individual por tipo de notificação
  - Controle de dias de antecedência
  - Frequência de notificações
  - Horário preferencial
  - Ativação/desativação por tipo

#### Jobs Automáticos
- **ExpirationNotificationJob**
  - Execução agendada (daily/hourly)
  - Verificação de alimentos próximos ao vencimento
  - Envio automático de notificações
  - Respeita preferências do usuário
  - Evita duplicatas

#### Interface Web
- **Página de Notificações** (`/notifications`)
  - Lista de todas as notificações
  - Filtros por status e tipo
  - Ações de marcar como lida
  - Indicador de notificações não lidas

- **Preferências de Notificações** (`/notification_preferences`)
  - Formulário de configuração
  - Toggle para cada tipo de notificação
  - Configuração de dias de antecedência
  - Preview de configurações

- **Modal de Permissão**
  - Solicitação de permissão ao usuário
  - Explicação clara do benefício
  - Gerenciamento de subscription
  - Feedback visual de status

#### API REST
- `GET /api/v1/notifications` - Listar notificações
- `POST /api/v1/notifications/subscribe` - Registrar subscription
- `DELETE /api/v1/notifications/unsubscribe` - Remover subscription
- `PATCH /api/v1/notifications/:id/read` - Marcar como lida
- `GET /api/v1/notification_preferences` - Obter preferências
- `PATCH /api/v1/notification_preferences/:id` - Atualizar preferências

---

## [1.1.0] - 2025-11-08

### ✨ Progressive Web App (PWA)

#### Funcionalidade Offline
- **Service Worker**
  - Cache de assets estáticos
  - Cache de páginas visitadas
  - Estratégia Network First para dados dinâmicos
  - Sincronização em background quando online

- **Manifest PWA**
  - Instalável como app nativo
  - Ícone personalizado
  - Nome e descrição
  - Tema de cores
  - Modo standalone

#### Experiência do Usuário
- **Instalação**
  - Prompt de instalação automático
  - Funciona em dispositivos móveis
  - Funciona em desktop (Chrome, Edge)

- **Modo Offline**
  - Navegação funcional sem internet
  - Dados em cache acessíveis
  - Indicador visual de modo offline
  - Sincronização automática ao retornar online

#### Suporte Técnico
- **Compatibilidade**
  - Chrome/Edge (Android e Desktop)
  - Firefox (parcial)
  - Safari (iOS) - suporte limitado

---

## [1.0.0] - 2025-11-07

### ✨ Gerenciamento de Alimentos (Food Items)

#### CRUD Completo
- **Criação de Alimentos**
  - Nome do item
  - Categoria (Grãos, Enlatados, Temperos, etc.)
  - Quantidade e unidade de medida
  - Local de armazenamento
  - Data de validade
  - Status (disponível, a vencer, vencido)

- **Listagem de Alimentos**
  - Visualização em cards
  - Indicadores visuais por status
  - Informação de dias até vencimento
  - Ordenação por data de validade
  - Paginação

- **Edição e Exclusão**
  - Formulário de edição completo
  - Confirmação de exclusão
  - Validações em tempo real

#### Filtros e Busca
- **Filtros Avançados**
  - Por status (disponível, a vencer, vencido)
  - Por categoria
  - Por local de armazenamento
  - Combinação de filtros

- **Busca**
  - Busca por nome
  - Busca case-insensitive

#### Dashboard
- **Visão Geral**
  - Contador de itens por status
  - Alertas de vencimento próximo
  - Lista de itens vencidos
  - Estatísticas gerais

- **Cards Informativos**
  - Cores por status (verde, amarelo, vermelho)
  - Ícones intuitivos
  - Informações resumidas

#### Cálculos Automáticos
- **Status Dinâmico**
  - Atualização automática baseada em data
  - "A vencer" (próximo 7 dias)
  - "Vencido" (data passada)
  - "Disponível" (mais de 7 dias)

- **Dias até Vencimento**
  - Cálculo automático
  - Exibição amigável
  - Indicador visual

#### Interface Hotwire
- **Turbo Drive**
  - Navegação SPA-like
  - Sem recarregamento de página
  - Transições suaves

- **Turbo Frames**
  - Formulários inline
  - Atualização parcial de página
  - Loading states

- **Stimulus Controllers**
  - Interatividade JavaScript
  - Validações client-side
  - Feedback visual

#### API REST
- **Endpoints Base**
  - `GET /api/v1/food_items` - Listar alimentos
  - `GET /api/v1/food_items/:id` - Detalhes do alimento
  - `POST /api/v1/food_items` - Criar alimento
  - `PATCH /api/v1/food_items/:id` - Atualizar alimento
  - `DELETE /api/v1/food_items/:id` - Deletar alimento

- **Filtros via Query Parameters**
  - `?filter=` - Filtrar por status
  - `?category=` - Filtrar por categoria
  - `?storage_location=` - Filtrar por local
  - `?query=` - Busca por nome

- **Formato de Resposta**
  - JSON estruturado
  - Metadados de paginação
  - Códigos HTTP apropriados
  - Mensagens de erro descritivas

#### Validações
- **Model Validations**
  - Nome obrigatório
  - Quantidade numérica e positiva
  - Data de validade válida
  - Categoria em lista pré-definida
  - Status em lista pré-definida

- **Feedback de Erros**
  - Mensagens em português
  - Indicadores visuais
  - Validação client e server-side

---

## 📊 Resumo de Features por Versão

### v1.4.0 - Sistema de Backup
- Export/Import de dados completos
- Validação e merge inteligente
- Interface de gerenciamento

### v1.3.0 - Sistema FIFO
- Gerenciamento de lotes
- Rotação automática de estoque
- Sugestões inteligentes de consumo

### v1.2.0 - Notificações Push
- Web Push Notifications
- Configuração de preferências
- Jobs automáticos de verificação

### v1.1.0 - PWA
- Service Worker com cache offline
- Instalável como app nativo
- Sincronização em background

### v1.0.0 - Food Items
- CRUD completo de alimentos
- Dashboard com estatísticas
- API REST completa
- Filtros e busca avançada

---

## 🎯 Métricas de Implementação

### Total de Features Implementadas
- ✅ **5 módulos principais**
- ✅ **20+ endpoints de API**
- ✅ **15+ páginas web**
- ✅ **30+ componentes Stimulus**
- ✅ **3 background jobs**

### Cobertura de Testes
- ✅ Models: 100%
- ✅ Controllers: 95%+
- ✅ API: 100%
- ✅ Services: 100%
- ✅ Jobs: 90%+

---

## 🔜 Roadmap de Features

### Versão 2.0
- [ ] Autenticação e autorização (Devise)
- [ ] Multi-usuário com compartilhamento
- [ ] Integração com scanner de código de barras
- [ ] Relatórios e gráficos avançados
- [ ] Sincronização multi-dispositivo
- [ ] Modo família (múltiplos estoques)

### Versão 2.1
- [ ] Receitas baseadas em ingredientes disponíveis
- [ ] Sugestões de compras (lista automática)
- [ ] Integração com supermercados (preços)
- [ ] Histórico de consumo e estatísticas
- [ ] Alertas inteligentes de reposição

### Versão 2.2
- [ ] Machine Learning para previsão de consumo
- [ ] Integração com assistentes de voz
- [ ] Widget para tela inicial
- [ ] Modo dark/light
- [ ] Temas personalizáveis

---

## 📞 Contribuindo

Para propor novas features:
1. Abra uma issue no GitHub descrevendo a feature
2. Aguarde discussão e aprovação
3. Desenvolva seguindo TDD (testes primeiro)
4. Abra PR com documentação atualizada

---

## 📝 Convenções deste Changelog

### O que É Documentado
- ✅ Novas funcionalidades visíveis ao usuário
- ✅ Novos endpoints de API
- ✅ Novos comportamentos do sistema
- ✅ Novas páginas ou componentes principais

### O que NÃO É Documentado
- ❌ Correções de bugs (fixes)
- ❌ Refatorações de código
- ❌ Melhorias de performance
- ❌ Atualizações de dependências
- ❌ Mudanças de infraestrutura

*Para mudanças de infraestrutura e scripts, consulte [CHANGELOG_SCRIPTS.md](CHANGELOG_SCRIPTS.md)*

---

**Criado por:** JML Consult Tech  
**Última atualização:** 12 de Novembro de 2025  
**Versão atual:** 1.4.0  
**Status:** 🚀 Em desenvolvimento ativo


