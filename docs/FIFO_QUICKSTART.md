# 🚀 Guia Rápido - Sistema FIFO de Rotatividade

## ⚡ Início Rápido (5 minutos)

### 1. Acessar a Aplicação

```bash
# A aplicação já está rodando em:
http://localhost:3000
```

### 2. Criar um Lote

**Via Web:**
1. Vá para "Lotes de Suprimentos" no menu
2. Clique em "+ Novo Lote"
3. Preencha os dados:
   - Alimento: Selecione um existente
   - Quantidade Inicial: Ex: 10.5
   - Data de Entrada: Hoje
   - Data de Validade: Daqui a 6 meses
   - Código do Lote: Ex: LOTE-2024-001
4. Clique em "Criar Lote"

**Via API:**
```bash
curl -X POST http://localhost:3000/api/v1/supply_batches \
  -H "Content-Type: application/json" \
  -d '{
    "supply_batch": {
      "food_item_id": 1,
      "initial_quantity": 10.5,
      "entry_date": "2024-11-09",
      "expiration_date": "2025-05-09",
      "batch_code": "LOTE-2024-001"
    }
  }'
```

### 3. Consumir do Lote (FIFO)

**Via Web:**
1. Na listagem de lotes, clique em "Consumir" no card do lote
2. Digite a quantidade a consumir
3. Selecione o tipo (Consumo, Descarte, etc.)
4. Clique em "Confirmar Consumo"

**Via API - Consumo Direto:**
```bash
curl -X POST http://localhost:3000/api/v1/supply_batches/1/consume \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 2.5,
    "rotation_type": "consumption",
    "reason": "Uso diário"
  }'
```

**Via API - Consumo FIFO Automático:**
```bash
curl -X POST http://localhost:3000/api/v1/supply_rotations/consume_fifo \
  -H "Content-Type: application/json" \
  -d '{
    "food_item_id": 1,
    "quantity": 5.0,
    "rotation_type": "consumption"
  }'
```

### 4. Ver Ordem FIFO

**Via Web:**
Acesse: `/supply_batches/fifo_order`

**Via API:**
```bash
curl http://localhost:3000/api/v1/supply_batches/fifo_order
```

### 5. Ver Estatísticas

**Via API:**
```bash
# Estatísticas de lotes
curl http://localhost:3000/api/v1/supply_batches/statistics

# Estatísticas de rotações
curl http://localhost:3000/api/v1/supply_rotations/statistics

# Estatísticas de um alimento específico
curl http://localhost:3000/api/v1/supply_rotations/statistics?food_item_id=1
```

## 📋 Fluxo de Trabalho Recomendado

### Cenário 1: Nova Compra

1. **Cadastrar o lote** ao receber a compra
2. Sistema atualiza automaticamente a quantidade total do alimento
3. Lote entra na fila FIFO baseado na validade

### Cenário 2: Consumo Diário

1. **Consumir usando FIFO automático**
2. Sistema seleciona automaticamente o(s) lote(s) com maior prioridade
3. Registra a rotação e atualiza quantidades

### Cenário 3: Descarte de Vencidos

1. Sistema identifica lotes vencidos (status visual)
2. **Registrar descarte** com motivo
3. Lote é marcado como "expired" ou "depleted"

### Cenário 4: Monitoramento

1. **Ver dashboard de lotes** - ordem FIFO
2. **Verificar estatísticas** - taxa de desperdício
3. **Analisar histórico** - padrões de consumo

## 🎯 Exemplos de Casos de Uso

### Caso 1: Múltiplos Lotes do Mesmo Alimento

```ruby
# Console Rails
arroz = FoodItem.find_by(name: "Arroz")

# Lote 1 - Vence em 30 dias
arroz.supply_batches.create!(
  initial_quantity: 5.0,
  entry_date: Date.today - 60.days,
  expiration_date: Date.today + 30.days,
  batch_code: "ARROZ-001"
)

# Lote 2 - Vence em 90 dias
arroz.supply_batches.create!(
  initial_quantity: 10.0,
  entry_date: Date.today,
  expiration_date: Date.today + 90.days,
  batch_code: "ARROZ-002"
)

# Consumir 7kg - FIFO consome 5kg do Lote 1 e 2kg do Lote 2
arroz.consume_fifo!(7.0, rotation_type: 'consumption')
```

### Caso 2: Lote sem Validade

```ruby
# Lotes sem validade são ordenados pela data de entrada
sal = FoodItem.find_by(name: "Sal")

sal.supply_batches.create!(
  initial_quantity: 20.0,
  entry_date: Date.today - 90.days,
  expiration_date: nil,  # Sem validade
  batch_code: "SAL-001"
)

# Este lote será consumido antes de lotes mais novos,
# mesmo que não tenha data de validade
```

### Caso 3: Rastreamento de Custos

```ruby
# Lotes com custo unitário
feijao = FoodItem.find_by(name: "Feijão")

lote = feijao.supply_batches.create!(
  initial_quantity: 15.0,
  entry_date: Date.today,
  expiration_date: Date.today + 180.days,
  batch_code: "FEIJAO-001",
  supplier: "Fornecedor ABC",
  unit_cost: 8.50  # R$ 8,50 por kg
)

# Custo total do lote
custo_total = lote.initial_quantity * lote.unit_cost  # R$ 127,50
```

## 🔍 Endpoints Úteis

```bash
# Listar todos os lotes ativos
GET /api/v1/supply_batches?status=active

# Listar lotes vencendo nos próximos 7 dias
GET /api/v1/supply_batches?expiring_soon=true

# Listar rotações de consumo
GET /api/v1/supply_rotations?rotation_type=consumption

# Listar rotações de desperdício
GET /api/v1/supply_rotations?rotation_type=waste

# Estatísticas do mês atual
GET /api/v1/supply_rotations/statistics?start_date=2024-11-01&end_date=2024-11-30
```

## 🐛 Troubleshooting

### Erro: "Insufficient quantity in batch"
**Causa**: Tentando consumir mais do que há disponível no lote.
**Solução**: Verifique `batch.current_quantity` antes de consumir.

### Erro: "Quantity must be positive"
**Causa**: Tentando consumir quantidade zero ou negativa.
**Solução**: Use valores positivos maiores que 0.

### Lote não aparece na ordem FIFO
**Causa**: Lote pode estar com status "depleted" ou "expired".
**Solução**: Verifique o status do lote em `/supply_batches/:id`.

## 📊 Métricas Importantes

### Taxa de Desperdício
```ruby
# Ideal: < 5%
SupplyRotation.calculate_waste_percentage
```

### Tempo Médio de Rotação
```ruby
# Tempo médio entre entrada e consumo completo de um lote
batches = SupplyBatch.depleted
avg_days = batches.map { |b| (b.updated_at.to_date - b.entry_date).to_i }.sum / batches.count
```

### Lotes Próximos ao Vencimento
```ruby
# Atenção se > 10% dos lotes ativos
expiring = SupplyBatch.expiring_soon(7).count
active = SupplyBatch.active.count
percentage = (expiring.to_f / active * 100).round(2)
```

## 💡 Dicas de Uso

1. **Sempre defina data de validade** quando aplicável - isso otimiza o FIFO
2. **Use códigos de lote descritivos** - facilita rastreabilidade
3. **Registre o fornecedor** - ajuda na análise de qualidade
4. **Documente motivos de descarte** - auxilia na redução de desperdício
5. **Revise estatísticas mensalmente** - identifique padrões e otimize

## 🔗 Links Úteis

- Documentação Completa: `FIFO_ROTATION_SYSTEM.md`
- API Documentation: `API_DOCUMENTATION.md`
- Código Fonte: `app/models/supply_batch.rb`

---

**Desenvolvido com ❤️ usando Ruby on Rails 8 + Hotwire**

