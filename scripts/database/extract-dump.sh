#!/bin/bash

# Configurações do banco de dados
CONTAINER_NAME="liferay-portal-7.4_db" # Substitua pelo nome do serviço MySQL no seu docker-compose.yml
DB_USER="root"                        # Substitua pelo usuário do banco
DB_PASSWORD="root"               # Substitua pela senha do banco
DB_NAME="lportal"                     # Nome do banco de dados
DUMP_FILE="dump.sql"          # Nome do arquivo de saída

# Verifica se o container está em execução
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Erro: O container ${CONTAINER_NAME} não está em execução."
  exit 1
fi

# Gera o dump do banco de dados
echo "Gerando dump do banco de dados ${DB_NAME}..."
docker exec -i "$CONTAINER_NAME" mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$DUMP_FILE"

# Verifica se o dump foi gerado com sucesso
if [ $? -eq 0 ]; then
  echo "Dump gerado com sucesso: ${DUMP_FILE}"
else
  echo "Erro ao gerar o dump."
  exit 1
fi
