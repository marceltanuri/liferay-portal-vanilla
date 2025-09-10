.PHONY: logs

# Define a variável SERVICE, que pode ser passada via linha de comando.
SERVICE ?=

logs: ## Mostra os logs dos contêineres (opcional: service=<nome_do_serviço>).
	@echo "==> Exibindo logs..."
	@if [ -z "$(SERVICE)" ]; then \
		echo "==> Mostrando logs de todos os serviços. Use 'make logs service=<nome>' para um serviço específico."; \
		docker compose logs -f; \
	else \
		echo "==> Mostrando logs do serviço: $(SERVICE)"; \
		docker compose logs -f $(SERVICE); \
	fi