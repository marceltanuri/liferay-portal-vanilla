.PHONY: up
LICENSE_SOURCE_DIR := license
LICENSE_TARGET_DIR := liferay/license

# Monta o parâmetro de build somente se v vier setado
ifeq ($(strip $(v)),)
BUILD_ARGS :=
else
BUILD_ARGS := --build-arg LIFERAY_VERSION=$(v)
endif

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
	@if [ -n "$(v)" ]; then \
		echo "==> Build com LIFERAY_VERSION=$(v)"; \
	else \
		echo "==> Build usando o default do Dockerfile (ARG LIFERAY_VERSION=latest)"; \
	fi
	@docker compose build $(BUILD_ARGS)
	@docker compose up -d
