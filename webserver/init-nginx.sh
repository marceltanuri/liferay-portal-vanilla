#!/bin/bash

# Verificar e criar o diretório de certificados
mkdir -p /etc/nginx/certs

# Gerar o certificado SSL se não existir
if [ ! -f /etc/nginx/certs/selfsigned.crt ] || [ ! -f /etc/nginx/certs/selfsigned.key ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/selfsigned.key \
    -out /etc/nginx/certs/selfsigned.crt \
    -subj "/C=US/ST=California/L=San Francisco/O=MyCompany/OU=IT/CN=localhost"
fi

# Iniciar o NGINX
nginx -g "daemon off;"
