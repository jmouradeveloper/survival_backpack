#!/bin/bash -e

# Se o banco de dados não existir, criá-lo e executar migrations
if [ ! -f /rails/storage/development.sqlite3 ]; then
  echo "Criando banco de dados..."
  bin/rails db:create
fi

echo "Executando migrations..."
bin/rails db:migrate

echo "Carregando seeds (se necessário)..."
bin/rails db:seed || true

exec "$@"

