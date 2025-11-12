# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🧹 Limpando dados existentes..."
SupplyRotation.destroy_all
SupplyBatch.destroy_all
Notification.destroy_all
NotificationPreference.destroy_all
FoodItem.destroy_all

puts "\n📦 Criando alimentos de exemplo..."

# Criar categorias comuns
categories = ["Grãos", "Enlatados", "Conservas", "Desidratados", "Bebidas", "Laticínios", "Proteínas", "Frutas", "Vegetais"]
storage_locations = ["Despensa", "Geladeira", "Freezer", "Armário"]

# Criar alimentos base (sem quantidade inicial, será calculada pelos lotes)
food_items_data = [
  {
    name: "Arroz Integral",
    category: "Grãos",
    quantity: 0,
    expiration_date: Date.today + 6.months,
    storage_location: "Despensa",
    notes: "Rico em fibras e nutrientes"
  },
  {
    name: "Feijão Preto",
    category: "Grãos",
    quantity: 0,
    expiration_date: Date.today + 8.months,
    storage_location: "Despensa",
    notes: "Excelente fonte de proteína vegetal"
  },
  {
    name: "Atum em Lata",
    category: "Enlatados",
    quantity: 0,
    expiration_date: Date.today + 2.years,
    storage_location: "Despensa",
    notes: "Proteína de longa durabilidade"
  },
  {
    name: "Milho em Conserva",
    category: "Conservas",
    quantity: 0,
    expiration_date: Date.today + 1.year,
    storage_location: "Despensa",
    notes: "Latas de 200g"
  },
  {
    name: "Leite em Pó",
    category: "Laticínios",
    quantity: 0,
    expiration_date: Date.today + 10.months,
    storage_location: "Despensa",
    notes: "Lata de 400g"
  },
  {
    name: "Macarrão",
    category: "Grãos",
    quantity: 0,
    expiration_date: Date.today + 1.year,
    storage_location: "Despensa",
    notes: "Pacotes de 500g"
  },
  {
    name: "Água Mineral",
    category: "Bebidas",
    quantity: 0,
    expiration_date: Date.today + 2.years,
    storage_location: "Armário",
    notes: "Garrafas de 1.5L"
  },
  {
    name: "Sardinha em Lata",
    category: "Enlatados",
    quantity: 0,
    expiration_date: Date.today + 18.months,
    storage_location: "Despensa",
    notes: "Rica em ômega 3"
  },
  {
    name: "Granola",
    category: "Desidratados",
    quantity: 0,
    expiration_date: Date.today + 4.months,
    storage_location: "Despensa",
    notes: "Mix de cereais e frutas secas"
  },
  {
    name: "Batata Desidratada",
    category: "Desidratados",
    quantity: 0,
    expiration_date: Date.today + 3.days,
    storage_location: "Despensa",
    notes: "Vencendo em breve! Usar logo"
  },
  {
    name: "Café em Pó",
    category: "Bebidas",
    quantity: 0,
    expiration_date: Date.today + 1.year,
    storage_location: "Despensa",
    notes: "Pacotes de 500g"
  },
  {
    name: "Açúcar",
    category: "Grãos",
    quantity: 0,
    expiration_date: nil,
    storage_location: "Despensa",
    notes: "Produto sem validade"
  }
]

food_items = {}
food_items_data.each do |item_attrs|
  item = FoodItem.create!(item_attrs)
  food_items[item.name] = item
  puts "  ✓ #{item.name}"
end

puts "\n📊 Criando lotes de suprimentos (Supply Batches)..."

# Array para armazenar os batches criados para uso posterior
supply_batches = []

# Arroz Integral - Múltiplos lotes com diferentes datas
arroz = food_items["Arroz Integral"]
batch1 = SupplyBatch.create!(
  food_item: arroz,
  initial_quantity: 5.0,
  entry_date: Date.today - 60.days,
  expiration_date: Date.today + 4.months,
  batch_code: "ARR-2024-001",
  supplier: "Fornecedor A",
  unit_cost: 4.50,
  notes: "Primeiro lote - mais antigo",
  status: 'active'
)
supply_batches << batch1

batch2 = SupplyBatch.create!(
  food_item: arroz,
  initial_quantity: 10.0,
  entry_date: Date.today - 30.days,
  expiration_date: Date.today + 6.months,
  batch_code: "ARR-2024-002",
  supplier: "Fornecedor B",
  unit_cost: 4.20,
  notes: "Segundo lote - mais recente",
  status: 'active'
)
supply_batches << batch2

puts "  ✓ Arroz Integral: 2 lotes criados"

# Feijão Preto - Lote parcialmente consumido
feijao = food_items["Feijão Preto"]
batch3 = SupplyBatch.create!(
  food_item: feijao,
  initial_quantity: 8.0,
  current_quantity: 3.5,
  entry_date: Date.today - 45.days,
  expiration_date: Date.today + 7.months,
  batch_code: "FEJ-2024-001",
  supplier: "Fornecedor A",
  unit_cost: 6.00,
  notes: "Lote parcialmente consumido",
  status: 'active'
)
supply_batches << batch3

puts "  ✓ Feijão Preto: 1 lote criado"

# Atum em Lata - Lote vencendo em breve
atum = food_items["Atum em Lata"]
batch4 = SupplyBatch.create!(
  food_item: atum,
  initial_quantity: 24,
  entry_date: Date.today - 90.days,
  expiration_date: Date.today + 5.days,
  batch_code: "ATM-2024-001",
  supplier: "Pescados Mar Azul",
  unit_cost: 8.50,
  notes: "URGENTE: Vence em 5 dias!",
  status: 'active'
)
supply_batches << batch4

batch5 = SupplyBatch.create!(
  food_item: atum,
  initial_quantity: 36,
  entry_date: Date.today - 10.days,
  expiration_date: Date.today + 2.years,
  batch_code: "ATM-2025-001",
  supplier: "Pescados Mar Azul",
  unit_cost: 7.80,
  notes: "Lote novo com validade longa",
  status: 'active'
)
supply_batches << batch5

puts "  ✓ Atum em Lata: 2 lotes criados"

# Milho em Conserva - Lote esgotado
milho = food_items["Milho em Conserva"]
batch6 = SupplyBatch.create!(
  food_item: milho,
  initial_quantity: 12,
  current_quantity: 0,
  entry_date: Date.today - 120.days,
  expiration_date: Date.today - 10.days,
  batch_code: "MLH-2023-005",
  supplier: "Conservas do Sul",
  unit_cost: 3.50,
  notes: "Lote totalmente consumido",
  status: 'depleted'
)
supply_batches << batch6

batch7 = SupplyBatch.create!(
  food_item: milho,
  initial_quantity: 18,
  entry_date: Date.today - 20.days,
  expiration_date: Date.today + 10.months,
  batch_code: "MLH-2024-001",
  supplier: "Conservas do Sul",
  unit_cost: 3.20,
  notes: "Lote novo ativo",
  status: 'active'
)
supply_batches << batch7

puts "  ✓ Milho em Conserva: 2 lotes criados"

# Leite em Pó
leite = food_items["Leite em Pó"]
batch8 = SupplyBatch.create!(
  food_item: leite,
  initial_quantity: 4.0,
  entry_date: Date.today - 15.days,
  expiration_date: Date.today + 9.months,
  batch_code: "LTP-2024-003",
  supplier: "Laticínios União",
  unit_cost: 15.00,
  notes: "Lata de 400g cada",
  status: 'active'
)
supply_batches << batch8

puts "  ✓ Leite em Pó: 1 lote criado"

# Macarrão - Múltiplos lotes
macarrao = food_items["Macarrão"]
batch9 = SupplyBatch.create!(
  food_item: macarrao,
  initial_quantity: 10.0,
  entry_date: Date.today - 50.days,
  expiration_date: Date.today + 8.months,
  batch_code: "MAC-2024-001",
  supplier: "Massas Boa Vista",
  unit_cost: 2.50,
  notes: "Lote mais antigo",
  status: 'active'
)
supply_batches << batch9

batch10 = SupplyBatch.create!(
  food_item: macarrao,
  initial_quantity: 15.0,
  entry_date: Date.today - 5.days,
  expiration_date: Date.today + 1.year,
  batch_code: "MAC-2024-002",
  supplier: "Massas Boa Vista",
  unit_cost: 2.30,
  notes: "Lote mais recente",
  status: 'active'
)
supply_batches << batch10

puts "  ✓ Macarrão: 2 lotes criados"

# Água Mineral
agua = food_items["Água Mineral"]
batch11 = SupplyBatch.create!(
  food_item: agua,
  initial_quantity: 48,
  entry_date: Date.today - 30.days,
  expiration_date: Date.today + 18.months,
  batch_code: "AGM-2024-008",
  supplier: "Águas Cristalinas",
  unit_cost: 1.50,
  notes: "Garrafas de 1.5L",
  status: 'active'
)
supply_batches << batch11

puts "  ✓ Água Mineral: 1 lote criado"

# Sardinha em Lata - Lote vencido
sardinha = food_items["Sardinha em Lata"]
batch12 = SupplyBatch.create!(
  food_item: sardinha,
  initial_quantity: 20,
  current_quantity: 0,
  entry_date: Date.today - 730.days,
  expiration_date: Date.today - 30.days,
  batch_code: "SAR-2022-012",
  supplier: "Conservas Oceano",
  unit_cost: 5.00,
  notes: "Lote vencido e descartado",
  status: 'expired'
)
supply_batches << batch12

batch13 = SupplyBatch.create!(
  food_item: sardinha,
  initial_quantity: 30,
  entry_date: Date.today - 25.days,
  expiration_date: Date.today + 16.months,
  batch_code: "SAR-2024-003",
  supplier: "Conservas Oceano",
  unit_cost: 4.50,
  notes: "Lote novo",
  status: 'active'
)
supply_batches << batch13

puts "  ✓ Sardinha em Lata: 2 lotes criados"

# Granola
granola = food_items["Granola"]
batch14 = SupplyBatch.create!(
  food_item: granola,
  initial_quantity: 3.0,
  entry_date: Date.today - 40.days,
  expiration_date: Date.today + 3.months,
  batch_code: "GRN-2024-006",
  supplier: "Natureza Viva",
  unit_cost: 12.00,
  notes: "Mix premium",
  status: 'active'
)
supply_batches << batch14

puts "  ✓ Granola: 1 lote criado"

# Batata Desidratada - Vencendo urgente
batata = food_items["Batata Desidratada"]
batch15 = SupplyBatch.create!(
  food_item: batata,
  initial_quantity: 5.0,
  entry_date: Date.today - 180.days,
  expiration_date: Date.today + 2.days,
  batch_code: "BTD-2024-001",
  supplier: "Desidratados Brasil",
  unit_cost: 8.00,
  notes: "URGENTE: Vence em 2 dias!",
  status: 'active'
)
supply_batches << batch15

puts "  ✓ Batata Desidratada: 1 lote criado"

# Café em Pó
cafe = food_items["Café em Pó"]
batch16 = SupplyBatch.create!(
  food_item: cafe,
  initial_quantity: 6.0,
  entry_date: Date.today - 20.days,
  expiration_date: Date.today + 11.months,
  batch_code: "CAF-2024-015",
  supplier: "Cafés Premium",
  unit_cost: 18.00,
  notes: "Café premium torrado e moído",
  status: 'active'
)
supply_batches << batch16

puts "  ✓ Café em Pó: 1 lote criado"

# Açúcar - Sem validade
acucar = food_items["Açúcar"]
batch17 = SupplyBatch.create!(
  food_item: acucar,
  initial_quantity: 20.0,
  entry_date: Date.today - 100.days,
  expiration_date: nil,
  batch_code: "ACR-2024-005",
  supplier: "Usina Santa Clara",
  unit_cost: 2.80,
  notes: "Produto sem validade definida",
  status: 'active'
)
supply_batches << batch17

puts "  ✓ Açúcar: 1 lote criado"

puts "\n🔄 Criando rotações de suprimentos (Supply Rotations)..."

# Rotações de consumo
rotation1 = SupplyRotation.create!(
  supply_batch: batch3,
  food_item: feijao,
  quantity: 2.5,
  rotation_date: Date.today - 20.days,
  rotation_type: 'consumption',
  reason: "Preparação de refeições",
  notes: "Consumo regular da semana"
)

rotation2 = SupplyRotation.create!(
  supply_batch: batch3,
  food_item: feijao,
  quantity: 2.0,
  rotation_date: Date.today - 10.days,
  rotation_type: 'consumption',
  reason: "Preparação de refeições",
  notes: "Consumo regular da semana"
)

puts "  ✓ 2 rotações de consumo (Feijão)"

# Rotação de desperdício do lote vencido
rotation3 = SupplyRotation.create!(
  supply_batch: batch12,
  food_item: sardinha,
  quantity: 20,
  rotation_date: Date.today - 30.days,
  rotation_type: 'waste',
  reason: "Produto vencido",
  notes: "Descartado por estar vencido há 30 dias"
)

puts "  ✓ 1 rotação de desperdício (Sardinha vencida)"

# Rotação de consumo do lote esgotado de milho
rotation4 = SupplyRotation.create!(
  supply_batch: batch6,
  food_item: milho,
  quantity: 8,
  rotation_date: Date.today - 50.days,
  rotation_type: 'consumption',
  reason: "Preparação de refeições",
  notes: "Primeira parte do lote"
)

rotation5 = SupplyRotation.create!(
  supply_batch: batch6,
  food_item: milho,
  quantity: 4,
  rotation_date: Date.today - 25.days,
  rotation_type: 'consumption',
  reason: "Preparação de refeições",
  notes: "Segunda parte do lote - completamente esgotado"
)

puts "  ✓ 2 rotações de consumo (Milho - lote esgotado)"

# Rotação de doação
rotation6 = SupplyRotation.create!(
  supply_batch: batch1,
  food_item: arroz,
  quantity: 2.0,
  rotation_date: Date.today - 15.days,
  rotation_type: 'donation',
  reason: "Doação para instituição de caridade",
  notes: "Doado para Casa de Apoio São José"
)

puts "  ✓ 1 rotação de doação (Arroz)"

# Atualizar a quantidade atual do batch1 de arroz
batch1.update!(current_quantity: batch1.current_quantity - 2.0)

# Rotação de transferência
rotation7 = SupplyRotation.create!(
  supply_batch: batch11,
  food_item: agua,
  quantity: 12,
  rotation_date: Date.today - 5.days,
  rotation_type: 'transfer',
  reason: "Transferência para estoque secundário",
  notes: "Movido para depósito auxiliar"
)

puts "  ✓ 1 rotação de transferência (Água)"

# Atualizar a quantidade atual do batch11 de água
batch11.update!(current_quantity: batch11.current_quantity - 12.0)

# Mais algumas rotações de consumo recentes
rotation8 = SupplyRotation.create!(
  supply_batch: batch9,
  food_item: macarrao,
  quantity: 1.5,
  rotation_date: Date.today - 3.days,
  rotation_type: 'consumption',
  reason: "Preparação de refeições",
  notes: "Consumo da última semana"
)

batch9.update!(current_quantity: batch9.current_quantity - 1.5)

rotation9 = SupplyRotation.create!(
  supply_batch: batch14,
  food_item: granola,
  quantity: 0.5,
  rotation_date: Date.today - 1.day,
  rotation_type: 'consumption',
  reason: "Café da manhã",
  notes: "Consumo diário"
)

batch14.update!(current_quantity: batch14.current_quantity - 0.5)

puts "  ✓ 2 rotações de consumo recentes (Macarrão e Granola)"

puts "\n🔔 Criando preferências de notificação..."

notification_pref = NotificationPreference.create!(
  days_before_expiration: 7,
  enable_push_notifications: true,
  enable_email_notifications: false,
  last_checked_at: DateTime.now
)

puts "  ✓ Preferências criadas (notificar 7 dias antes)"

puts "\n📬 Criando notificações de exemplo..."

# Notificação para atum vencendo
notif1 = Notification.create!(
  food_item: atum,
  title: "⚠️ Atum vencendo em breve!",
  body: "O lote #{batch4.batch_code} de #{atum.name} vence em 5 dias. Consuma logo!",
  notification_type: "expiration_warning",
  read: false,
  sent_at: DateTime.now - 1.hour,
  priority: 2
)

# Notificação para batata vencendo urgente
notif2 = Notification.create!(
  food_item: batata,
  title: "🚨 URGENTE: Batata Desidratada vencendo!",
  body: "O lote #{batch15.batch_code} de #{batata.name} vence em 2 dias. USAR IMEDIATAMENTE!",
  notification_type: "expiration_warning",
  read: false,
  sent_at: DateTime.now - 30.minutes,
  priority: 3
)

# Notificação já lida
notif3 = Notification.create!(
  food_item: milho,
  title: "✅ Lote de milho totalmente consumido",
  body: "O lote #{batch6.batch_code} foi totalmente consumido.",
  notification_type: "expiration_warning",
  read: true,
  sent_at: DateTime.now - 2.days,
  priority: 0
)

puts "  ✓ 3 notificações criadas"

puts "\n" + "="*80
puts "✅ SEEDS CRIADOS COM SUCESSO!"
puts "="*80

puts "\n📊 RESUMO GERAL:"
puts "\n🍲 Alimentos:"
puts "  Total: #{FoodItem.count}"
FoodItem.group(:category).count.each do |category, count|
  puts "    #{category}: #{count}"
end

puts "\n📦 Lotes (Supply Batches):"
puts "  Total: #{SupplyBatch.count}"
puts "  Ativos: #{SupplyBatch.active.count}"
puts "  Esgotados: #{SupplyBatch.depleted.count}"
puts "  Vencidos: #{SupplyBatch.expired.count}"
puts "  Vencendo em breve (7 dias): #{SupplyBatch.expiring_soon(7).count}"

puts "\n🔄 Rotações (Supply Rotations):"
puts "  Total: #{SupplyRotation.count}"
puts "  Consumo: #{SupplyRotation.consumption.count}"
puts "  Desperdício: #{SupplyRotation.waste.count}"
puts "  Doação: #{SupplyRotation.donation.count}"
puts "  Transferência: #{SupplyRotation.transfer.count}"

stats = SupplyRotation.statistics
puts "\n📈 Estatísticas de Rotação:"
puts "  Quantidade total rotacionada: #{stats[:total_quantity]}"
puts "  Percentual de desperdício: #{stats[:waste_percentage]}%"

puts "\n🔔 Notificações:"
puts "  Total: #{Notification.count}"
puts "  Não lidas: #{Notification.where(read: false).count}"
puts "  Lidas: #{Notification.where(read: true).count}"

puts "\n⚙️  Preferências de Notificação:"
puts "  Notificar com: #{notification_pref.days_before_expiration} dias de antecedência"
puts "  Push notifications: #{notification_pref.enable_push_notifications ? 'Ativadas' : 'Desativadas'}"
puts "  Email notifications: #{notification_pref.enable_email_notifications ? 'Ativadas' : 'Desativadas'}"

puts "\n💡 CENÁRIOS DE TESTE DISPONÍVEIS:"
puts "  1. Sistema FIFO - Múltiplos lotes de Arroz e Macarrão"
puts "  2. Lotes vencendo - Atum (5 dias) e Batata (2 dias)"
puts "  3. Lote vencido - Sardinha (30 dias atrás)"
puts "  4. Lote esgotado - Milho (totalmente consumido)"
puts "  5. Lote parcialmente consumido - Feijão"
puts "  6. Produto sem validade - Açúcar"
puts "  7. Rotações diversas - consumption, waste, donation, transfer"
puts "  8. Notificações urgentes e normais"
puts "\n" + "="*80
