#!/bin/bash

echo "🎒 Survival Backpack - Script de Teste de Notificações"
echo "======================================================="
echo ""

echo "1️⃣ Criando preferências de notificação..."
docker compose exec -T web bin/rails runner "
  pref = NotificationPreference.current
  puts '✅ Preferências criadas: #{pref.days_before_expiration} dias antes'
"

echo ""
echo "2️⃣ Criando alimentos de teste com diferentes validades..."
docker compose exec -T web bin/rails runner "
  # Alimento vencendo hoje
  FoodItem.create!(
    name: 'Leite Integral',
    category: 'Laticínios',
    quantity: 1,
    expiration_date: Date.today,
    storage_location: 'Geladeira'
  )
  puts '✅ Leite (vence hoje)'
  
  # Alimento vencendo amanhã
  FoodItem.create!(
    name: 'Iogurte Natural',
    category: 'Laticínios',
    quantity: 2,
    expiration_date: Date.today + 1.day,
    storage_location: 'Geladeira'
  )
  puts '✅ Iogurte (vence amanhã)'
  
  # Alimento vencendo em 3 dias
  FoodItem.create!(
    name: 'Queijo Minas',
    category: 'Laticínios',
    quantity: 1,
    expiration_date: Date.today + 3.days,
    storage_location: 'Geladeira'
  )
  puts '✅ Queijo (vence em 3 dias)'
  
  # Alimento vencendo em 7 dias
  FoodItem.create!(
    name: 'Pão Integral',
    category: 'Padaria',
    quantity: 1,
    expiration_date: Date.today + 7.days,
    storage_location: 'Despensa'
  )
  puts '✅ Pão (vence em 7 dias)'
  
  # Alimento com validade boa
  FoodItem.create!(
    name: 'Arroz Integral',
    category: 'Grãos',
    quantity: 5,
    expiration_date: Date.today + 6.months,
    storage_location: 'Despensa'
  )
  puts '✅ Arroz (vence em 6 meses)'
"

echo ""
echo "3️⃣ Executando job de verificação de validades..."
docker compose exec -T web bin/rails runner "
  ExpirationNotificationJob.perform_now
  puts '✅ Job executado!'
"

echo ""
echo "4️⃣ Verificando notificações criadas..."
docker compose exec -T web bin/rails runner "
  total = Notification.count
  unread = Notification.unread.count
  by_type = Notification.group(:notification_type).count
  
  puts '📊 Estatísticas:'
  puts '   Total de notificações: #{total}'
  puts '   Não lidas: #{unread}'
  puts '   Por tipo:'
  by_type.each do |type, count|
    puts '     - #{type}: #{count}'
  end
  
  puts ''
  puts '📬 Últimas notificações:'
  Notification.order(created_at: :desc).limit(5).each do |n|
    status = n.read? ? '✓' : '●'
    priority_icon = case n.priority
      when 2 then '🔴'
      when 1 then '🟡'
      else '🔵'
    end
    puts \"   #{status} #{priority_icon} #{n.title}\"
  end
"

echo ""
echo "✅ Script de teste concluído!"
echo ""
echo "📝 Próximos passos:"
echo "   1. Acesse: http://localhost:3000"
echo "   2. Vá para 'Notificações' para ver os alertas"
echo "   3. Configure preferências em 'Configurações'"
echo "   4. Ative as push notifications no navegador"
echo ""

