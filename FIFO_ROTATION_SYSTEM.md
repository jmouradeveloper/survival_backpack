# 📦 Sistema de Controle de Rotatividade FIFO (First In First Out)

## 📋 Visão Geral

Este documento descreve a funcionalidade de controle de rotatividade de suprimentos utilizando a estratégia **FIFO (First In First Out)**, garantindo que os alimentos com validade mais próxima sejam consumidos primeiro, minimizando desperdícios e otimizando o gerenciamento de estoque.

## 🎯 Objetivos

1. **Rastrear lotes individuais** de alimentos com suas datas de entrada e validade
2. **Implementar estratégia FIFO** para consumo automático dos itens mais antigos
3. **Minimizar desperdícios** através do controle inteligente de validade
4. **Fornecer visibilidade completa** do histórico de rotações
5. **Calcular estatísticas** de consumo e desperdício

## 🏗️ Arquitetura

### Modelos de Dados

#### 1. SupplyBatch (Lote de Suprimento)

Representa um lote individual de um alimento, com sua própria data de entrada e validade.

**Campos principais:**
- `food_item_id`: Referência ao alimento
- `initial_quantity`: Quantidade inicial do lote
- `current_quantity`: Quantidade atual disponível
- `entry_date`: Data de entrada no estoque
- `expiration_date`: Data de validade (opcional)
- `batch_code`: Código identificador do lote
- `supplier`: Fornecedor
- `unit_cost`: Custo unitário
- `status`: Estado do lote (active, depleted, expired)

**Métodos principais:**
- `consume!(quantity, options)`: Consome quantidade do lote
- `priority_score`: Calcula prioridade FIFO (menor = maior prioridade)
- `available?`: Verifica se o lote está disponível para consumo
- `expired?`: Verifica se está vencido
- `expiring_soon?(days)`: Verifica se está próximo do vencimento

**Scopes úteis:**
```ruby
SupplyBatch.active               # Lotes ativos
SupplyBatch.by_fifo_order        # Ordenados por prioridade FIFO
SupplyBatch.expiring_soon(7)    # Vencendo nos próximos 7 dias
SupplyBatch.next_to_consume      # Próximo lote a ser consumido
```

#### 2. SupplyRotation (Rotação/Consumo)

Registra cada movimentação de consumo, descarte ou transferência de um lote.

**Campos principais:**
- `supply_batch_id`: Lote consumido
- `food_item_id`: Alimento
- `quantity`: Quantidade consumida
- `rotation_date`: Data da rotação
- `rotation_type`: Tipo (consumption, waste, donation, transfer)
- `reason`: Motivo da rotação
- `notes`: Observações

**Métodos estáticos:**
```ruby
SupplyRotation.statistics(start_date, end_date)  # Estatísticas do período
SupplyRotation.total_consumed(food_item_id)     # Total consumido
SupplyRotation.total_wasted(food_item_id)       # Total desperdiçado
```

#### 3. FoodItem (Alimento) - Atualizado

Agora possui métodos para trabalhar com lotes e FIFO:

**Novos métodos:**
```ruby
food_item.active_batches                     # Lotes ativos ordenados por FIFO
food_item.next_batch_to_consume              # Próximo lote a consumir
food_item.total_batch_quantity               # Quantidade total em lotes
food_item.consume_fifo!(quantity, options)   # Consome usando FIFO
food_item.batch_statistics                   # Estatísticas dos lotes
```

### Algoritmo FIFO

O algoritmo de priorização FIFO funciona da seguinte forma:

1. **Lotes com validade definida**: Ordenados pela data de validade (mais próxima primeiro)
2. **Lotes sem validade**: Ordenados pela data de entrada (mais antigo primeiro)
3. **Ajustes de prioridade**:
   - Lotes vencidos têm prioridade máxima (-10000 no score)
   - Lotes com menos de 10% da quantidade inicial têm prioridade alta (-100 no score)

```ruby
def priority_score
  return Float::INFINITY unless available?
  
  base_score = if expiration_date.present?
    days_until_expiration || 0
  else
    (Date.today - entry_date).to_i + 1000
  end
  
  base_score -= 10000 if expired?
  base_score -= 100 if current_quantity < (initial_quantity * 0.1)
  
  base_score
end
```

## 🔌 API REST

### Supply Batches

#### Listar Lotes
```bash
GET /api/v1/supply_batches
GET /api/v1/supply_batches?food_item_id=1
GET /api/v1/supply_batches?status=active
GET /api/v1/supply_batches?sort=recent
GET /api/v1/supply_batches?page=1&per_page=20
```

#### Ver Lote Específico
```bash
GET /api/v1/supply_batches/:id
```

#### Criar Lote
```bash
POST /api/v1/supply_batches
Content-Type: application/json

{
  "supply_batch": {
    "food_item_id": 1,
    "initial_quantity": 10.5,
    "entry_date": "2024-11-09",
    "expiration_date": "2025-02-09",
    "batch_code": "LOTE-2024-001",
    "supplier": "Fornecedor ABC",
    "unit_cost": 5.50,
    "notes": "Observações do lote"
  }
}
```

#### Atualizar Lote
```bash
PUT /api/v1/supply_batches/:id
Content-Type: application/json

{
  "supply_batch": {
    "current_quantity": 8.5,
    "notes": "Atualização"
  }
}
```

#### Consumir do Lote
```bash
POST /api/v1/supply_batches/:id/consume
Content-Type: application/json

{
  "quantity": 2.5,
  "rotation_type": "consumption",
  "reason": "Uso diário",
  "notes": "Observações do consumo"
}
```

#### Ordem FIFO
```bash
GET /api/v1/supply_batches/fifo_order
GET /api/v1/supply_batches/fifo_order?food_item_id=1
```

#### Estatísticas
```bash
GET /api/v1/supply_batches/statistics
GET /api/v1/supply_batches/statistics?food_item_id=1
```

### Supply Rotations

#### Listar Rotações
```bash
GET /api/v1/supply_rotations
GET /api/v1/supply_rotations?food_item_id=1
GET /api/v1/supply_rotations?rotation_type=consumption
GET /api/v1/supply_rotations?start_date=2024-01-01&end_date=2024-12-31
```

#### Criar Rotação (Consumo Manual)
```bash
POST /api/v1/supply_rotations
Content-Type: application/json

{
  "supply_rotation": {
    "supply_batch_id": 1,
    "food_item_id": 1,
    "quantity": 2.5,
    "rotation_date": "2024-11-09",
    "rotation_type": "consumption",
    "reason": "Uso diário",
    "notes": "Observações"
  }
}
```

#### Consumir com FIFO Automático
```bash
POST /api/v1/supply_rotations/consume_fifo
Content-Type: application/json

{
  "food_item_id": 1,
  "quantity": 5.0,
  "rotation_type": "consumption",
  "reason": "Uso diário",
  "notes": "Consumo automático FIFO"
}
```

Este endpoint consumirá automaticamente dos lotes com maior prioridade FIFO, distribuindo a quantidade entre múltiplos lotes se necessário.

#### Estatísticas
```bash
GET /api/v1/supply_rotations/statistics
GET /api/v1/supply_rotations/statistics?food_item_id=1
GET /api/v1/supply_rotations/statistics?start_date=2024-01-01&end_date=2024-12-31
```

## 🌐 Interface Web

### Páginas Disponíveis

#### 1. Listagem de Lotes
**URL**: `/supply_batches`

Exibe todos os lotes cadastrados com:
- Filtros por alimento, status e ordenação
- Cards visuais com informações do lote
- Indicadores de prioridade FIFO
- Barras de progresso de consumo
- Ações rápidas (ver, consumir, editar, excluir)

#### 2. Detalhes do Lote
**URL**: `/supply_batches/:id`

Mostra informações completas do lote:
- Estatísticas detalhadas
- Histórico de rotações
- Ações de consumo e edição

#### 3. Criar/Editar Lote
**URLs**: `/supply_batches/new`, `/supply_batches/:id/edit`

Formulário modal com:
- Seleção de alimento
- Quantidades inicial e atual
- Datas de entrada e validade
- Código do lote e fornecedor
- Custo unitário
- Observações

#### 4. Histórico de Rotações
**URL**: `/supply_rotations`

Lista todas as rotações com:
- Filtros por alimento, tipo e período
- Estatísticas de consumo e desperdício
- Detalhes de cada rotação

#### 5. Ordem FIFO
**URL**: `/supply_batches/fifo_order`

Visualiza a ordem de prioridade FIFO dos lotes.

## 🎨 Recursos Hotwire

### Turbo Frames
- Formulários modais sem recarregar a página
- Atualizações parciais da lista
- Navegação rápida entre páginas

### Turbo Streams
- Criação instantânea de lotes
- Atualização em tempo real após consumo
- Remoção suave de itens

### Stimulus Controllers

#### `supply-batch-controller.js`
Gerencia interações dos lotes:
- `showConsumeModal()`: Exibe modal de consumo
- `createConsumeModal()`: Cria modal dinamicamente
- `closeModal()`: Fecha modal

## 📊 Exemplos de Uso

### Exemplo 1: Criar e Consumir Lote

```ruby
# 1. Criar alimento
arroz = FoodItem.create!(
  name: "Arroz Integral",
  category: "Grãos",
  quantity: 0
)

# 2. Criar lote
lote = SupplyBatch.create!(
  food_item: arroz,
  initial_quantity: 10.0,
  entry_date: Date.today,
  expiration_date: Date.today + 180.days,
  batch_code: "ARROZ-2024-001",
  supplier: "Fornecedor ABC"
)

# 3. Consumir do lote
lote.consume!(2.5, 
  rotation_type: 'consumption',
  reason: 'Uso diário'
)

# 4. Verificar quantidade
lote.reload
lote.current_quantity # => 7.5
arroz.reload
arroz.quantity # => 7.5 (atualizado automaticamente)
```

### Exemplo 2: Consumo FIFO Automático

```ruby
arroz = FoodItem.find_by(name: "Arroz Integral")

# Criar múltiplos lotes com diferentes validades
lote1 = arroz.supply_batches.create!(
  initial_quantity: 5.0,
  entry_date: Date.today - 30.days,
  expiration_date: Date.today + 60.days,
  batch_code: "LOTE-001"
)

lote2 = arroz.supply_batches.create!(
  initial_quantity: 8.0,
  entry_date: Date.today,
  expiration_date: Date.today + 90.days,
  batch_code: "LOTE-002"
)

# Consumir 7kg usando FIFO
# Automaticamente consumirá 5kg do lote1 e 2kg do lote2
rotations = arroz.consume_fifo!(7.0, 
  rotation_type: 'consumption',
  reason: 'Preparo semanal'
)

rotations.size # => 2 (duas rotações criadas)
lote1.reload.current_quantity # => 0 (esgotado)
lote2.reload.current_quantity # => 6.0
```

### Exemplo 3: Estatísticas

```ruby
# Estatísticas de um alimento
arroz = FoodItem.find_by(name: "Arroz Integral")
stats = arroz.batch_statistics
# => {
#   total_batches: 5,
#   active_batches: 3,
#   depleted_batches: 2,
#   expired_batches: 0,
#   total_quantity: 18.5,
#   oldest_batch_date: "2024-01-15",
#   next_expiration_date: "2024-12-20"
# }

# Estatísticas de rotações
rotation_stats = SupplyRotation.statistics(
  Date.today.beginning_of_month,
  Date.today.end_of_month
)
# => {
#   total_rotations: 45,
#   total_quantity: 125.5,
#   by_type: {
#     consumption: 110.0,
#     waste: 5.5,
#     donation: 8.0,
#     transfer: 2.0
#   },
#   waste_percentage: 4.38
# }
```

## 🔧 Configuração e Deploy

### Executar Migrations

```bash
docker compose exec web bin/rails db:migrate
```

### Adicionar Dados de Teste

```ruby
# No console Rails
docker compose exec web bin/rails console

# Criar lotes de exemplo
food = FoodItem.first
3.times do |i|
  SupplyBatch.create!(
    food_item: food,
    initial_quantity: rand(5.0..15.0).round(2),
    entry_date: Date.today - (i * 30).days,
    expiration_date: Date.today + (180 - i * 30).days,
    batch_code: "LOTE-#{Date.today.year}-#{sprintf('%03d', i+1)}",
    supplier: "Fornecedor #{['A', 'B', 'C'][i]}"
  )
end
```

## 📱 Suporte Offline (PWA)

A funcionalidade está preparada para trabalhar offline através do Service Worker:

1. **Cache de Assets**: Views e controllers em cache
2. **IndexedDB**: Preparado para sincronização offline
3. **Estratégia Network First**: Tenta buscar online, fallback para cache

Para testar offline:
1. Acesse o aplicativo online
2. Abra DevTools > Application > Service Workers
3. Marque "Offline"
4. Navegue pela aplicação

## 🎯 Benefícios da Implementação

1. ✅ **Redução de Desperdício**: Consumo automático dos itens mais antigos
2. ✅ **Rastreabilidade Total**: Histórico completo de cada lote
3. ✅ **Visibilidade**: Dashboards e estatísticas em tempo real
4. ✅ **Eficiência**: Processo automático de seleção de lotes
5. ✅ **Conformidade**: Registro detalhado para auditorias
6. ✅ **Economia**: Controle de custos por lote e fornecedor
7. ✅ **Planejamento**: Alertas de vencimento e necessidade de reposição

## 📝 Próximas Melhorias Sugeridas

1. [ ] Alertas automáticos de lotes vencendo
2. [ ] Relatórios exportáveis (PDF/Excel)
3. [ ] Gráficos de consumo ao longo do tempo
4. [ ] Integração com código de barras
5. [ ] Previsão de necessidade de reposição
6. [ ] Comparação de fornecedores (custo x qualidade)
7. [ ] Integração com sistema de compras

## 🆘 Suporte

Para dúvidas ou problemas:
1. Consulte esta documentação
2. Verifique os logs: `docker compose logs web`
3. Execute testes: `docker compose exec web bin/rails test`
4. Consulte o código-fonte nos diretórios:
   - `app/models/supply_batch.rb`
   - `app/models/supply_rotation.rb`
   - `app/controllers/supply_batches_controller.rb`
   - `app/controllers/supply_rotations_controller.rb`

## 📚 Referências

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Hotwire Documentation](https://hotwired.dev/)
- [FIFO Inventory Management](https://en.wikipedia.org/wiki/FIFO_and_LIFO_accounting)

