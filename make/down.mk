down:
	@echo "==> Derrubando containers, removendo volumes e imagens locais..."
	@docker compose down --volumes --rmi local
	@rm	-f liferay/patching/*.zip
