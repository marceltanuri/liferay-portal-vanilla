# ==============================================================================
# up.mk - Lida com a inicialização e build do ambiente Docker.
# ==============================================================================

.PHONY: up _ensure-patch-dir _join-config _join-portal-ext _join-env-file _join-osgi-configs \
        _join-tomcat-configs _check-license _download-hotfix-if-needed \
        _download-hotfix _build-docker-images _inform-liferay-version _setup_env \
        _start-containers

# --- Variáveis de Build e Download ---

# Monta o parâmetro --build-arg para o Docker Compose somente se a variável 'v' (versão) for definida.
ifeq ($(strip $(v)),)
BUILD_ARGS :=
else
BUILD_ARGS := --build-arg LIFERAY_VERSION=$(v)
endif

# Variável para o diretório de ambiente externo
ENV_DIR ?=

# Diretórios para patching e arquivos de configuração que são montados como volumes.
PATCH_DIR := liferay/patching
CONFIG_DIR := liferay/config
DEFAULT_CONFIG_DIR := ${CONFIG_DIR}/default
CONFIG_ALL_DIR := ${CONFIG_DIR}/.all

DEFAULT_ENV_FILE := liferay/.default-env
FINAL_ENV_FILE := liferay/.all-env

# Arquivos de configuração
DEFAULT_PROPS_FILE := ${DEFAULT_CONFIG_DIR}/portal-ext.properties
FINAL_PROPS_FILE := $(CONFIG_ALL_DIR)/portal-ext.properties

# Define o nome do arquivo de hotfix e a URL de download com base nas variáveis 'v' e 'hotfix'.
HOTFIX_FILE := $(PATCH_DIR)/liferay-dxp-${v}-hotfix-$(hotfix).zip
HOTFIX_URL := https://releases-cdn.liferay.com/dxp/hotfix/$(v)/liferay-dxp-${v}-hotfix-$(hotfix).zip

# --- Alvos Principais ---

up: _setup_env ## Orquestra a subida do ambiente.

## _setup_env: Configura o ambiente a partir de um diretório externo ou executa o fluxo padrão.
_setup_env:
ifeq ($(strip $(ENV_DIR)),)
	# Fluxo padrão se ENV_DIR não for fornecido
	@$(MAKE) _standard_up v=$(v) hotfix=$(hotfix) FORCE_DOWNLOAD=$(FORCE_DOWNLOAD) --no-print-directory
else
	# Fluxo com ENV_DIR: carrega variáveis do arquivo .args e executa o fluxo padrão
	@echo "==> Configurando ambiente a partir de: $(ENV_DIR)"
	@if [ ! -d "$(ENV_DIR)" ]; then echo "ERRO: Diretório ENV_DIR não encontrado: $(ENV_DIR)"; exit 1; fi
	@if [ ! -d "$(ENV_DIR)/config" ]; then echo "ERRO: Diretório ENV_DIR/configs não encontrado: $(ENV_DIR)"; exit 1; fi
	@if [ ! -f "$(ENV_DIR)/.args" ]; then echo "ERRO: Arquivo .args não encontrado em $(ENV_DIR)"; exit 1; fi
	@echo "==> Carregando variáveis de $(ENV_DIR)/.args e iniciando o ambiente..."
	@$(MAKE) _standard_up `cat $(ENV_DIR)/.args` FORCE_DOWNLOAD=$(FORCE_DOWNLOAD) --no-print-directory
endif

## _standard_up: Alvo interno que contém o fluxo de execução padrão.
_standard_up: _ensure-patch-dir _join-config _check-license _download-hotfix-if-needed _build-docker-images _start-containers

## _check-license: Verifica a existência do arquivo de licença.
_check-license:
	@echo "==> Verificando a existência do arquivo de licença..."
	@if [ ! -f liferay/license/activation-key.xml ]; then echo "ERRO: Arquivo de licença não encontrado em 'liferay/license/activation-key.xml'."; exit 1; fi
	@echo "==> Arquivo de licença encontrado."
	@if [ ! -s liferay/license/activation-key.xml ]; then echo "ERRO: Arquivo de licença 'liferay/license/activation-key.xml' está vazio."; exit 1; fi
	@echo "==> Arquivo de licença não está vazio."
	@cp liferay/license/activation-key.xml liferay/deploy/ 
	
## _inform-liferay-version: Informa a versão do Liferay que será utilizada no build.
_inform-liferay-version:
	@if [ -n "$(v)" ]; then \
		echo "==> Build com LIFERAY_VERSION=$(v)"; \
	else \
		echo "==> Build usando o default do Dockerfile (ARG LIFERAY_VERSION=latest)"; \
	fi
	
## _download-hotfix-if-needed: Faz o download do hotfix, se a variável 'hotfix' foi passada.
_download-hotfix-if-needed:
ifeq ($(strip $(hotfix)),)
	@echo "==> Nenhum HOTFIX informado. Prosseguindo sem aplicar hotfix."
else
	# Chama o alvo 'download-hotfix' de forma recursiva.
	@$(MAKE) _download-hotfix v=$(v) hotfix=$(hotfix) --no-print-directory
endif
	
## _build-docker-images: Constrói as imagens Docker.
_build-docker-images: _inform-liferay-version
	@docker compose build $(BUILD_ARGS)
	
## _start-containers: Inicia os contêineres em modo detached.
_start-containers:
	@docker compose up -d

## _download-hotfix: Baixa um arquivo de hotfix específico.
_download-hotfix: _ensure-patch-dir
	# Valida se as variáveis 'v' e 'hotfix' foram informadas.
ifeq ($(strip $(v)),)
	$(error É necessário informar a versão: make up v=2024.q2.8 hotfix=48)
endif
ifeq ($(strip $(hotfix)),)
	$(error É necessário informar o hotfix: make up v=2024.q2.8 hotfix=48)
endif
	# Verifica se o arquivo já existe, a menos que FORCE_DOWNLOAD seja 1.
	@if [ -f "$(HOTFIX_FILE)" ] && [ "$(FORCE_DOWNLOAD)" != "1" ]; then \
		echo "==> Hotfix já existe em $(HOTFIX_FILE). Use 'make download-hotfix FORCE_DOWNLOAD=1 ...' para forçar novo download."; \
	else \
		echo "==> Baixando hotfix $(hotfix) da versão $(v)..."; \
		echo "==> URL: $(HOTFIX_URL)"; \
		curl -fL --retry 3 --retry-delay 2 -o "$(HOTFIX_FILE).part" "$(HOTFIX_URL)" && \
		  mv "$(HOTFIX_FILE).part" "$(HOTFIX_FILE)" || (rm -f "$(HOTFIX_FILE).part" && exit 1); \
		echo "==> Hotfix salvo em $(HOTFIX_FILE)"; \
	fi

# --- Alvos Internos Auxiliares de Configuração ---

## _ensure-patch-dir: Garante que o diretório de patching exista.
_ensure-patch-dir:
	@mkdir -p "$(PATCH_DIR)"

## _join-config: Une as configurações padrão e customizadas em um único arquivo.
_join-config: _join-portal-ext _join-osgi-configs _join-env-file _join-tomcat-configs
	@echo "==> Todas as configurações foram unidas com sucesso."

## _join-portal-ext: Une os arquivos portal-ext.properties padrão e customizado.
_join-portal-ext:
	@echo "==> Gerando arquivo de configuração final em $(FINAL_PROPS_FILE)..."
	# Garante que o diretório de destino exista.
	@mkdir -p "$(CONFIG_ALL_DIR)"
	# Começa com o arquivo padrão.
	@cp "$(DEFAULT_PROPS_FILE)" "$(FINAL_PROPS_FILE)"
	# Anexa o conteúdo de cada arquivo portal-*.properties encontrado no diretório customizado.
	@echo "==> Lendo arquivos de configuração customizados em $(ENV_DIR)"
	@if [ -d "$(ENV_DIR)" ]; then \
		for custom_file in $(ENV_DIR)/portal-*.properties; do \
			echo "==> Lendo arquivo de configuração customizado $$custom_file"; \
			if [ -f "$$custom_file" ]; then \
				echo "" >> "$(FINAL_PROPS_FILE)"; \
				echo "# --- Custom Properties (from $$custom_file) ---" >> "$(FINAL_PROPS_FILE)"; \
				cat "$$custom_file" >> "$(FINAL_PROPS_FILE)"; \
				echo "==> Configurações de '$$custom_file' foram aplicadas."; \
			fi \
		done \
	fi
	@echo "==> Arquivo portal-ext.properties gerado com sucesso."


## _join-env-file: Une os arquivos .env padrão e customizado.
_join-env-file:
	@echo "==> Gerando arquivo de configuração final em $(FINAL_ENV_FILE)..."
	# Começa com o arquivo padrão.
	@cp "$(DEFAULT_ENV_FILE)" "$(FINAL_ENV_FILE)"
	# Anexa o conteúdo de cada arquivo .*env encontrado no diretório customizado.
	@echo "==> Lendo arquivos .env customizados em $(ENV_DIR)"
	@if [ -d "$(ENV_DIR)" ]; then \
		for custom_file in $(ENV_DIR)/.*env; do \
		echo "==> Lendo arquivo de .env customizado $$custom_file"; \
			if [ -f "$$custom_file" ]; then \
				echo "" >> "$(FINAL_ENV_FILE)"; \
				echo "# --- Custom env (from $$custom_file) ---" >> "$(FINAL_ENV_FILE)"; \
				cat "$$custom_file" >> "$(FINAL_ENV_FILE)"; \
				echo "==> Configurações de '$$custom_file' foram aplicadas."; \
			fi \
		done \
	fi
	@echo "==> Arquivo .-all-env gerado com sucesso."

## _join-osgi-configs: Une as configurações OSGi padrão e customizadas.
_join-osgi-configs:
	@echo "==> Unindo configurações OSGi..."
	# Garante que os diretórios de destino existam
	@mkdir -p "$(CONFIG_ALL_DIR)/osgi/configs"
	@mkdir -p "$(CONFIG_ALL_DIR)/osgi/modules"

	# Copia recursivamente, permitindo que 'custom' sobrescreva 'default'.
	@cp -r $(DEFAULT_CONFIG_DIR)/osgi/configs/* "$(CONFIG_ALL_DIR)/osgi/configs/" 2>/dev/null || true
	@cp -r $(ENV_DIR)/config/osgi/configs/* "$(CONFIG_ALL_DIR)/osgi/configs/" 2>/dev/null || true
	@cp -r $(ENV_DIR)/config/osgi/modules/* "$(CONFIG_ALL_DIR)/osgi/modules/" 2>/dev/null || true
	@echo "==> Configurações OSGi unidas com sucesso."

## _join-tomcat-configs: Une as configurações do Tomcat padrão e customizadas.
_join-tomcat-configs:
	# Garante que os diretórios de destino existam.
	@mkdir -p "$(CONFIG_ALL_DIR)/tomcat/lib"
	# Copia recursivamente, permitindo que 'custom' sobrescreva 'default'.
	@cp -r $(DEFAULT_CONFIG_DIR)/tomcat/* "$(CONFIG_ALL_DIR)/tomcat/" 2>/dev/null || true
	@cp -r $(ENV_DIR)/config/tomcat/* "$(CONFIG_ALL_DIR)/tomcat/" 2>/dev/null || true
	@cp -r $(DEFAULT_CONFIG_DIR)/tomcat/lib/* "$(CONFIG_ALL_DIR)/tomcat/lib/" 2>/dev/null || true
	@cp -r $(ENV_DIR)/config/tomcat/lib/* "$(CONFIG_ALL_DIR)/tomcat/lib/" 2>/dev/null || true
	@echo "==> Configurações do Tomcat unidas com sucesso."
