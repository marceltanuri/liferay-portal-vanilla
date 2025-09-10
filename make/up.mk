.PHONY: up ensure-patch-dir download-hotfix

# Monta o parâmetro de build somente se v vier setado
ifeq ($(strip $(v)),)
BUILD_ARGS :=
else
BUILD_ARGS := --build-arg LIFERAY_VERSION=$(v)
endif

PATCH_DIR := liferay/patching
HOTFIX_FILE := $(PATCH_DIR)/liferay-dxp-${v}-hotfix-$(hotfix).zip
HOTFIX_URL := https://releases-cdn.liferay.com/dxp/hotfix/$(v)/liferay-dxp-${v}-hotfix-$(hotfix).zip

up: ensure-patch-dir
	@echo "==> Verificando a existência do arquivo de licença..."
	@if [ ! -f "liferay/license/activation-key.xml" ]; then \
		echo "ERRO: Arquivo de licença não encontrado em 'liferay/license/activation-key.xml'."; \
		exit 1; \
	fi

	@if [ -n "$(v)" ]; then \
		echo "==> Build com LIFERAY_VERSION=$(v)"; \
	else \
		echo "==> Build usando o default do Dockerfile (ARG LIFERAY_VERSION=latest)"; \
	fi

# Faz download do hotfix se 'hotfix' foi passado
ifeq ($(strip $(hotfix)),)
	@echo "==> Nenhum HOTFIX informado. Prosseguindo sem aplicar hotfix."
else
	@$(MAKE) download-hotfix v=$(v) hotfix=$(hotfix) --no-print-directory
endif

	@docker compose build $(BUILD_ARGS)
	@docker compose up -d

ensure-patch-dir:
	@mkdir -p "$(PATCH_DIR)"

download-hotfix: ensure-patch-dir
ifeq ($(strip $(v)),)
	$(error É necessário informar a versão: make up v=2024.q2.8 hotfix=48)
endif
ifeq ($(strip $(hotfix)),)
	$(error É necessário informar o hotfix: make up v=2024.q2.8 hotfix=48)
endif
	@if [ -f "$(HOTFIX_FILE)" ]; then \
		echo "==> Hotfix já existe em $(HOTFIX_FILE). Use 'make download-hotfix FORCE_DOWNLOAD=1 ...' para forçar novo download."; \
	else \
		echo "==> Baixando hotfix $(hotfix) da versão $(v)"; \
		echo "==> URL: $(HOTFIX_URL)"; \
		curl -fL --retry 3 --retry-delay 2 -o "$(HOTFIX_FILE).part" "$(HOTFIX_URL)" && \
		  mv "$(HOTFIX_FILE).part" "$(HOTFIX_FILE)"; \
		echo "==> Hotfix salvo em $(HOTFIX_FILE)"; \
	fi
