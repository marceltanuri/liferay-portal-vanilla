reset-deploy: ## Limpa o diretório de deploy do Liferay.
	@echo "==> Limpando $(LICENSE_TARGET_DIR)..."
	@rm -rf $(LICENSE_TARGET_DIR)/*
