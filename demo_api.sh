#!/bin/bash

# Script de Demonstração - Survival Backpack
# Funcionalidade: Cadastro de Alimentos

echo "🎒 Survival Backpack - Demonstração da API"
echo "=========================================="
echo ""

BASE_URL="http://localhost:3000/api/v1"

echo "1️⃣  Verificando estatísticas iniciais..."
echo "GET ${BASE_URL}/food_items/statistics"
echo ""
curl -s "${BASE_URL}/food_items/statistics" | python3 -m json.tool
echo ""
echo "----------------------------------------"
echo ""

echo "2️⃣  Listando alimentos (primeiros 5)..."
echo "GET ${BASE_URL}/food_items?per_page=5"
echo ""
curl -s "${BASE_URL}/food_items?per_page=5" | python3 -m json.tool
echo ""
echo "----------------------------------------"
echo ""

echo "3️⃣  Filtrando alimentos vencendo em breve..."
echo "GET ${BASE_URL}/food_items?filter=expiring_soon"
echo ""
curl -s "${BASE_URL}/food_items?filter=expiring_soon" | python3 -m json.tool
echo ""
echo "----------------------------------------"
echo ""

echo "4️⃣  Criando novo alimento..."
echo "POST ${BASE_URL}/food_items"
echo ""
curl -s -X POST "${BASE_URL}/food_items" \
  -H "Content-Type: application/json" \
  -d '{
    "food_item": {
      "name": "Chocolate em Barra",
      "category": "Doces",
      "quantity": 3,
      "expiration_date": "2026-03-15",
      "storage_location": "Despensa",
      "notes": "Chocolate meio amargo 70% cacau"
    }
  }' | python3 -m json.tool
echo ""
echo "----------------------------------------"
echo ""

echo "5️⃣  Buscando alimento específico (ID: 1)..."
echo "GET ${BASE_URL}/food_items/1"
echo ""
curl -s "${BASE_URL}/food_items/1" | python3 -m json.tool
echo ""
echo "----------------------------------------"
echo ""

echo "6️⃣  Filtrando por categoria (Grãos)..."
echo "GET ${BASE_URL}/food_items?category=Grãos"
echo ""
curl -s "${BASE_URL}/food_items?category=Grãos" | python3 -m json.tool
echo ""
echo "----------------------------------------"
echo ""

echo "✅ Demonstração concluída!"
echo ""
echo "📝 Para mais informações:"
echo "   - Documentação da API: API_DOCUMENTATION.md"
echo "   - Documentação da Feature: FOOD_ITEMS_FEATURE.md"
echo "   - Resumo da Implementação: IMPLEMENTATION_SUMMARY.md"
echo ""
echo "🌐 Interface Web: http://localhost:3000"
echo "🔌 API Base URL: http://localhost:3000/api/v1"
echo ""

