down:
	@echo "==> Derrubando containers, removendo volumes e imagens locais..."
	@docker compose down --volumes --rmi local
