.PHONY: up

# Monta o parâmetro de build somente se v vier setado
ifeq ($(strip $(v)),)
BUILD_ARGS :=
else
BUILD_ARGS := --build-arg LIFERAY_VERSION=$(v)
endif

up:
	@echo "==> Verificando a existência do arquivo de licença..."
	@if [ ! -f "license/activation-key.xml" ]; then \
		echo "ERRO: Arquivo de licença não encontrado em 'license/activation-key.xml'."; \
		exit 1; \
	fi
	@if [ -n "$(v)" ]; then \
		echo "==> Build com LIFERAY_VERSION=$(v)"; \
	else \
		echo "==> Build usando o default do Dockerfile (ARG LIFERAY_VERSION=latest)"; \
	fi
	@docker compose build $(BUILD_ARGS)
	@docker compose up -d
