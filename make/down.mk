down: ## Para e remove os contêineres, redes, volumes e imagens locais.
	@echo "==> Derrubando containers, removendo volumes e imagens locais..."
	@docker compose down --volumes --rmi local
	@rm	-f liferay/patching/*.zip
	@rm -rf liferay/config/.all
	@rm -rf liferay/config/.custom
	@rm	-rf elasticsearch-data
	@rm	-rf liferay/document-library
	@rm	-rf liferay/deploy/*
	@rm	-rf echo "" > liferay/.all-env
