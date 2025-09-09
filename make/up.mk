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
