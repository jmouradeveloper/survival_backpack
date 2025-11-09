# Seeds para demonstração do Sistema FIFO

puts "🌱 Criando dados de exemplo para o Sistema FIFO..."

# Limpar dados anteriores de lotes e rotações (mas manter food_items)
SupplyRotation.destroy_all
SupplyBatch.destroy_all

# Encontrar ou criar alimentos
arroz = FoodItem.find_or_create_by!(name: "Arroz Integral") do |f|
  f.category = "Grãos"
  f.quantity = 0
  f.storage_location = "Despensa"
  f.notes = "Para consumo regular"
end

feijao = FoodItem.find_or_create_by!(name: "Feijão Preto") do |f|
  f.category = "Grãos"
  f.quantity = 0
  f.storage_location = "Despensa"
end

macarrao = FoodItem.find_or_create_by!(name: "Macarrão Integral") do |f|
  f.category = "Massas"
  f.quantity = 0
  f.storage_location = "Despensa"
end

# Criar lotes de arroz com diferentes validades (para demonstrar FIFO)
puts "  📦 Criando lotes de Arroz..."

lote_arroz_1 = arroz.supply_batches.create!(
  initial_quantity: 5.0,
  entry_date: Date.today - 60.days,
  expiration_date: Date.today + 30.days, # Vence em 30 dias - PRIORIDADE ALTA
  batch_code: "ARROZ-2024-001",
  supplier: "Fornecedor A",
  unit_cost: 7.50,
  notes: "Lote mais antigo - deve ser consumido primeiro"
)

lote_arroz_2 = arroz.supply_batches.create!(
  initial_quantity: 10.0,
  entry_date: Date.today - 15.days,
  expiration_date: Date.today + 90.days, # Vence em 90 dias
  batch_code: "ARROZ-2024-002",
  supplier: "Fornecedor B",
  unit_cost: 7.20,
  notes: "Lote intermediário"
)

lote_arroz_3 = arroz.supply_batches.create!(
  initial_quantity: 8.0,
  entry_date: Date.today,
  expiration_date: Date.today + 180.days, # Vence em 180 dias - PRIORIDADE BAIXA
  batch_code: "ARROZ-2024-003",
  supplier: "Fornecedor A",
  unit_cost: 7.80,
  notes: "Lote mais novo - será consumido por último"
)

# Criar lotes de feijão
puts "  📦 Criando lotes de Feijão..."

lote_feijao_1 = feijao.supply_batches.create!(
  initial_quantity: 6.0,
  entry_date: Date.today - 45.days,
  expiration_date: Date.today + 60.days,
  batch_code: "FEIJAO-2024-001",
  supplier: "Fornecedor C",
  unit_cost: 8.50
)

lote_feijao_2 = feijao.supply_batches.create!(
  initial_quantity: 12.0,
  entry_date: Date.today - 10.days,
  expiration_date: Date.today + 120.days,
  batch_code: "FEIJAO-2024-002",
  supplier: "Fornecedor B",
  unit_cost: 8.20
)

# Criar lote de macarrão sem validade (demonstra ordenação por data de entrada)
puts "  📦 Criando lote de Macarrão..."

lote_macarrao = macarrao.supply_batches.create!(
  initial_quantity: 15.0,
  entry_date: Date.today - 30.days,
  expiration_date: nil, # Sem validade definida
  batch_code: "MACARRAO-2024-001",
  supplier: "Fornecedor D",
  unit_cost: 5.50,
  notes: "Produto sem data de validade - ordenado por data de entrada"
)

# Simular alguns consumos (demonstra o histórico)
puts "  🔄 Criando registros de consumo..."

# Consumir 2kg do lote mais antigo de arroz
lote_arroz_1.consume!(
  2.0,
  rotation_type: 'consumption',
  reason: 'Preparo semanal',
  notes: 'Consumo normal - seguindo FIFO'
)

# Consumir 3kg de feijão
lote_feijao_1.consume!(
  3.0,
  rotation_type: 'consumption',
  reason: 'Preparo diário'
)

# Simular um descarte (produto vencido em lote hipotético)
# Vamos criar um lote vencido e descartá-lo
lote_vencido = arroz.supply_batches.create!(
  initial_quantity: 1.5,
  current_quantity: 1.5,
  entry_date: Date.today - 200.days,
  expiration_date: Date.today - 5.days, # Vencido há 5 dias
  batch_code: "ARROZ-2023-099",
  supplier: "Fornecedor Antigo",
  status: 'expired'
)

lote_vencido.consume!(
  1.5,
  rotation_type: 'waste',
  reason: 'Produto vencido',
  notes: 'Descartado por vencimento'
)

# Estatísticas finais
puts "\n✅ Dados criados com sucesso!"
puts "\n📊 Resumo:"
puts "  - #{FoodItem.count} alimentos cadastrados"
puts "  - #{SupplyBatch.count} lotes criados"
puts "  - #{SupplyBatch.active.count} lotes ativos"
puts "  - #{SupplyBatch.depleted.count} lotes esgotados"
puts "  - #{SupplyBatch.expired.count} lotes vencidos"
puts "  - #{SupplyRotation.count} rotações registradas"
puts "  - #{SupplyRotation.consumption.count} consumos"
puts "  - #{SupplyRotation.waste.count} descartes"

puts "\n🎯 Ordem FIFO atual para Arroz:"
arroz.reload.active_batches.each_with_index do |batch, index|
  puts "  #{index + 1}. #{batch.batch_code} - Prioridade: #{batch.priority_score} - Quantidade: #{batch.current_quantity}kg"
end

puts "\n📈 Estatísticas de Arroz:"
stats = arroz.batch_statistics
puts "  - Total em estoque: #{stats[:total_quantity]}kg"
puts "  - Lotes ativos: #{stats[:active_batches]}"
puts "  - Data mais antiga: #{stats[:oldest_batch_date]}"
puts "  - Próxima validade: #{stats[:next_expiration_date]}"

puts "\n🌐 Acesse:"
puts "  - Web: http://localhost:3000/supply_batches"
puts "  - API: http://localhost:3000/api/v1/supply_batches/fifo_order"
puts "\n✨ Sistema FIFO pronto para uso!"

