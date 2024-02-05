#!/bin/bash

# Diretório para armazenar os certificados
CERTS_DIR=/etc/nginx/certs

# Nome do domínio para o certificado
DOMAIN=meusite.com

# Verifica se o diretório certs existe, e se não, cria
if [ ! -d "$CERTS_DIR" ]; then
  mkdir -p "$CERTS_DIR"
fi

# Gera certificado e chave privada
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $CERTS_DIR/$DOMAIN.key -out $CERTS_DIR/$DOMAIN.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=$DOMAIN"

# Verifica se a geração de certificados foi bem-sucedida
if [ $? -ne 0 ]; then
  echo "Erro ao gerar certificados SSL. Saindo."
  exit 1
fi

# Ajusta as permissões do diretório e da chave privada
chmod 700 $CERTS_DIR
chmod 400 $CERTS_DIR/$DOMAIN.crt
chown -R nginx:nginx $CERTS_DIR

# Inicia o serviço Nginx
exec nginx -g 'daemon off;'
