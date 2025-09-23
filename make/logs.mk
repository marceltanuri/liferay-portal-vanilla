.PHONY: logs

# Extrai todos os argumentos passados para o make, exceto o próprio 'logs'.
ARGS := $(filter-out logs,$(MAKECMDGOALS))

logs: ## Mostra os logs dos contêineres (opcional: make logs <nome_do_serviço>).
	@echo $(ARGS);
	@echo "==> Exibindo logs..."
	@if [ -z "$(ARGS)" ]; then \
		echo "==> Mostrando logs de todos os serviços. Use 'make logs <nome_do_serviço>' para um serviço específico."; \
		docker compose logs -f; \
	else \
		echo "==> Mostrando logs do(s) serviço(s): $(ARGS)"; \
		docker compose logs -f $(ARGS); \
	fi
