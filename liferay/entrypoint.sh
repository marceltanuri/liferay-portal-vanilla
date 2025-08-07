#!/bin/bash

LICENSE_FILE="/tmp/license/activation-key.xml"
TARGET_FILE="/mnt/liferay/deploy/activation-key.xml"

if [ -f "$LICENSE_FILE" ] && [ ! -f "$TARGET_FILE" ]; then
  echo "Copiando licença para o volume de deploy..."
  cp "$LICENSE_FILE" "$TARGET_FILE"
fi

echo "Iniciando o Liferay..."
exec /opt/liferay/tomcat/bin/catalina.sh run
