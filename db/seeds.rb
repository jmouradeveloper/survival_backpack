# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Limpar dados existentes
FoodItem.destroy_all

# Criar categorias comuns
categories = ["Grãos", "Enlatados", "Conservas", "Desidratados", "Bebidas", "Laticínios", "Proteínas", "Frutas", "Vegetais"]
storage_locations = ["Despensa", "Geladeira", "Freezer", "Armário"]

# Criar alguns alimentos de exemplo
food_items = [
  {
    name: "Arroz Integral",
    category: "Grãos",
    quantity: 5.0,
    expiration_date: Date.today + 6.months,
    storage_location: "Despensa",
    notes: "Pacote de 5kg, rico em fibras"
  },
  {
    name: "Feijão Preto",
    category: "Grãos",
    quantity: 3.0,
    expiration_date: Date.today + 8.months,
    storage_location: "Despensa",
    notes: "Excelente fonte de proteína vegetal"
  },
  {
    name: "Atum em Lata",
    category: "Enlatados",
    quantity: 10,
    expiration_date: Date.today + 2.years,
    storage_location: "Despensa",
    notes: "Proteína de longa durabilidade"
  },
  {
    name: "Milho em Conserva",
    category: "Conservas",
    quantity: 8,
    expiration_date: Date.today + 1.year,
    storage_location: "Despensa",
    notes: "Latas de 200g"
  },
  {
    name: "Leite em Pó",
    category: "Laticínios",
    quantity: 2.0,
    expiration_date: Date.today + 10.months,
    storage_location: "Despensa",
    notes: "Lata de 400g"
  },
  {
    name: "Macarrão",
    category: "Grãos",
    quantity: 4.0,
    expiration_date: Date.today + 1.year,
    storage_location: "Despensa",
    notes: "Pacotes de 500g"
  },
  {
    name: "Água Mineral",
    category: "Bebidas",
    quantity: 20,
    expiration_date: Date.today + 2.years,
    storage_location: "Armário",
    notes: "Garrafas de 1.5L"
  },
  {
    name: "Sardinha em Lata",
    category: "Enlatados",
    quantity: 12,
    expiration_date: Date.today + 18.months,
    storage_location: "Despensa",
    notes: "Rica em ômega 3"
  },
  {
    name: "Granola",
    category: "Desidratados",
    quantity: 1.5,
    expiration_date: Date.today + 4.months,
    storage_location: "Despensa",
    notes: "Mix de cereais e frutas secas"
  },
  {
    name: "Batata Desidratada",
    category: "Desidratados",
    quantity: 2.0,
    expiration_date: Date.today + 3.days,
    storage_location: "Despensa",
    notes: "Vencendo em breve! Usar logo"
  }
]

food_items.each do |item_attrs|
  FoodItem.create!(item_attrs)
end

puts "✅ Criados #{FoodItem.count} alimentos de exemplo!"
puts "\nResumo por categoria:"
FoodItem.group(:category).count.each do |category, count|
  puts "  #{category}: #{count}"
end

puts "\nStatus dos alimentos:"
puts "  Válidos: #{FoodItem.valid_items.count}"
puts "  Vencendo em breve: #{FoodItem.expiring_soon.count}"
puts "  Vencidos: #{FoodItem.expired.count}"
