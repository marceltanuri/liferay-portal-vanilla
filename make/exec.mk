.PHONY: exec

# Extrai todos os argumentos passados para o make, exceto o próprio 'insp'.
ARGS_EXEC := $(filter-out exec,$(MAKECMDGOALS))

exec: ## Executa um shell bash dentro de um contêiner (ex: make insp liferay).
	docker compose exec -it $(ARGS_EXEC) /bin/bash;
