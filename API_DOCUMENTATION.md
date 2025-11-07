# API Documentation - Food Items

## Base URL
```
http://localhost:3000/api/v1
```

## Endpoints

### 1. Listar Alimentos
**GET** `/api/v1/food_items`

Lista todos os alimentos cadastrados com suporte a filtros e paginação.

#### Query Parameters
| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `filter` | string | Filtrar por status: `valid`, `expiring_soon`, `expired` |
| `category` | string | Filtrar por categoria |
| `storage_location` | string | Filtrar por local de armazenamento |
| `page` | integer | Página atual (padrão: 1) |
| `per_page` | integer | Itens por página (padrão: 20, máximo: 100) |

#### Exemplo de Request
```bash
curl http://localhost:3000/api/v1/food_items?filter=expiring_soon&page=1&per_page=10
```

#### Exemplo de Response
```json
{
  "data": [
    {
      "id": 1,
      "name": "Arroz Integral",
      "category": "Grãos",
      "quantity": "5.0",
      "expiration_date": "2025-05-07",
      "storage_location": "Despensa",
      "notes": "Pacote de 5kg",
      "created_at": "2025-11-07T17:42:10.000Z",
      "updated_at": "2025-11-07T17:42:10.000Z",
      "expired?": false,
      "expiring_soon?": false,
      "days_until_expiration": 181,
      "status": "valid"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 50
  }
}
```

---

### 2. Buscar Alimento por ID
**GET** `/api/v1/food_items/:id`

Retorna os detalhes de um alimento específico.

#### Exemplo de Request
```bash
curl http://localhost:3000/api/v1/food_items/1
```

#### Exemplo de Response
```json
{
  "data": {
    "id": 1,
    "name": "Arroz Integral",
    "category": "Grãos",
    "quantity": "5.0",
    "expiration_date": "2025-05-07",
    "storage_location": "Despensa",
    "notes": "Pacote de 5kg",
    "created_at": "2025-11-07T17:42:10.000Z",
    "updated_at": "2025-11-07T17:42:10.000Z",
    "expired?": false,
    "expiring_soon?": false,
    "days_until_expiration": 181,
    "status": "valid"
  }
}
```

---

### 3. Criar Alimento
**POST** `/api/v1/food_items`

Cria um novo alimento no estoque.

#### Request Body
```json
{
  "food_item": {
    "name": "Feijão Preto",
    "category": "Grãos",
    "quantity": 2.5,
    "expiration_date": "2025-12-31",
    "storage_location": "Despensa",
    "notes": "Pacote de 1kg"
  }
}
```

#### Exemplo de Request
```bash
curl -X POST http://localhost:3000/api/v1/food_items \
  -H "Content-Type: application/json" \
  -d '{
    "food_item": {
      "name": "Feijão Preto",
      "category": "Grãos",
      "quantity": 2.5,
      "expiration_date": "2025-12-31",
      "storage_location": "Despensa",
      "notes": "Pacote de 1kg"
    }
  }'
```

#### Exemplo de Response (Sucesso - 201)
```json
{
  "data": {
    "id": 11,
    "name": "Feijão Preto",
    "category": "Grãos",
    "quantity": "2.5",
    "expiration_date": "2025-12-31",
    "storage_location": "Despensa",
    "notes": "Pacote de 1kg",
    "created_at": "2025-11-07T18:00:00.000Z",
    "updated_at": "2025-11-07T18:00:00.000Z",
    "expired?": false,
    "expiring_soon?": false,
    "days_until_expiration": 419,
    "status": "valid"
  },
  "message": "Alimento cadastrado com sucesso"
}
```

#### Exemplo de Response (Erro - 422)
```json
{
  "error": "Erro ao cadastrar alimento",
  "details": [
    "Nome não pode ficar em branco",
    "Quantidade deve ser maior ou igual a 0"
  ]
}
```

---

### 4. Atualizar Alimento
**PUT/PATCH** `/api/v1/food_items/:id`

Atualiza os dados de um alimento existente.

#### Request Body
```json
{
  "food_item": {
    "quantity": 1.5,
    "notes": "Quantidade atualizada após uso"
  }
}
```

#### Exemplo de Request
```bash
curl -X PATCH http://localhost:3000/api/v1/food_items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "food_item": {
      "quantity": 1.5
    }
  }'
```

#### Exemplo de Response (Sucesso)
```json
{
  "data": {
    "id": 1,
    "name": "Arroz Integral",
    "category": "Grãos",
    "quantity": "1.5",
    "expiration_date": "2025-05-07",
    "storage_location": "Despensa",
    "notes": "Quantidade atualizada após uso",
    "created_at": "2025-11-07T17:42:10.000Z",
    "updated_at": "2025-11-07T18:05:00.000Z",
    "expired?": false,
    "expiring_soon?": false,
    "days_until_expiration": 181,
    "status": "valid"
  },
  "message": "Alimento atualizado com sucesso"
}
```

---

### 5. Deletar Alimento
**DELETE** `/api/v1/food_items/:id`

Remove um alimento do estoque.

#### Exemplo de Request
```bash
curl -X DELETE http://localhost:3000/api/v1/food_items/1
```

#### Exemplo de Response (Sucesso)
```json
{
  "message": "Alimento removido com sucesso"
}
```

---

### 6. Estatísticas
**GET** `/api/v1/food_items/statistics`

Retorna estatísticas gerais do estoque de alimentos.

#### Exemplo de Request
```bash
curl http://localhost:3000/api/v1/food_items/statistics
```

#### Exemplo de Response
```json
{
  "data": {
    "total": 10,
    "expired": 0,
    "expiring_soon": 1,
    "valid": 9,
    "by_category": {
      "Grãos": 3,
      "Enlatados": 2,
      "Conservas": 1,
      "Desidratados": 2,
      "Bebidas": 1,
      "Laticínios": 1
    },
    "by_storage_location": {
      "Despensa": 9,
      "Armário": 1
    }
  }
}
```

---

## Códigos de Status HTTP

| Código | Descrição |
|--------|-----------|
| 200 | OK - Requisição bem-sucedida |
| 201 | Created - Recurso criado com sucesso |
| 404 | Not Found - Recurso não encontrado |
| 422 | Unprocessable Entity - Erro de validação |
| 503 | Service Unavailable - Serviço offline |

---

## Campos do Modelo Food Item

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `name` | string | Sim | Nome do alimento (mín: 2, máx: 255 caracteres) |
| `category` | string | Sim | Categoria do alimento |
| `quantity` | decimal | Sim | Quantidade disponível (≥ 0) |
| `expiration_date` | date | Não | Data de validade |
| `storage_location` | string | Não | Local de armazenamento (máx: 255 caracteres) |
| `notes` | text | Não | Observações adicionais (máx: 5000 caracteres) |

---

## Categorias Sugeridas

- Grãos
- Enlatados
- Conservas
- Desidratados
- Bebidas
- Laticínios
- Proteínas
- Frutas
- Vegetais
- Outros

---

## Locais de Armazenamento Sugeridos

- Despensa
- Geladeira
- Freezer
- Armário
- Porão

---

## Funcionalidades Offline

A aplicação possui suporte para modo offline através de Service Worker:

1. **Cache de Assets**: CSS, JS e páginas principais são cacheados
2. **Network First**: Tenta buscar dados online primeiro, depois do cache
3. **Background Sync**: Sincroniza dados quando a conexão retornar

Para funcionalidades offline completas, considere implementar IndexedDB no frontend.

