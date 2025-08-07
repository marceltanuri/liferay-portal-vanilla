# Diretórios
LICENSE_SOURCE_DIR=./liferay/license
LICENSE_TARGET_DIR=./liferay/deploy

# Subir containers com build e copiar arquivos de licença se ainda não existirem
up:
	@echo "==> Verificando arquivos de licença..."
	@mkdir -p $(LICENSE_TARGET_DIR)
	@for file in $(LICENSE_SOURCE_DIR)/*.xml; do \
		filename=$$(basename $$file); \
		if [ -f "$$file" ] && [ ! -f "$(LICENSE_TARGET_DIR)/$$filename" ]; then \
			echo "==> Copiando $$filename para $(LICENSE_TARGET_DIR)"; \
			cp "$$file" "$(LICENSE_TARGET_DIR)/"; \
		else \
			echo "==> $$filename já existe ou não encontrado."; \
		fi; \
	done
	@echo "==> Subindo containers com build..."
	@docker compose up --build -d

# Derrubar containers e limpar volumes e imagens locais
down:
	@echo "==> Derrubando containers, removendo volumes e imagens locais..."
	@docker compose down --volumes --rmi local

# (Opcional) Limpar a pasta de deploy
reset-deploy:
	@echo "==> Limpando $(LICENSE_TARGET_DIR)..."
	@rm -rf $(LICENSE_TARGET_DIR)/*
