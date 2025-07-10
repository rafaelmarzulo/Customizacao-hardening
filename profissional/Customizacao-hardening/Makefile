# Makefile para automação do projeto

.PHONY: help install test lint clean backup setup-dev

# Variáveis
PROJECT_NAME := customizacao-hardening
INSTALL_DIR := /opt/$(PROJECT_NAME)
CONFIG_DIR := /etc/$(PROJECT_NAME)
LOG_DIR := /var/log/$(PROJECT_NAME)

# Ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  install     - Instalar o projeto no sistema"
	@echo "  test        - Executar testes"
	@echo "  lint        - Verificar qualidade do código"
	@echo "  clean       - Limpar arquivos temporários"
	@echo "  backup      - Fazer backup das configurações"
	@echo "  setup-dev   - Configurar ambiente de desenvolvimento"

# Instalação
install:
	@echo "Instalando $(PROJECT_NAME)..."
	sudo mkdir -p $(INSTALL_DIR) $(CONFIG_DIR) $(LOG_DIR)
	sudo cp -r scripts/ $(INSTALL_DIR)/
	sudo cp -r configs/ $(CONFIG_DIR)/
	sudo chmod +x $(INSTALL_DIR)/scripts/*/*.sh
	sudo ln -sf $(INSTALL_DIR)/scripts/hardening/ssh_hardening.sh /usr/local/bin/ssh-hardening
	sudo ln -sf $(INSTALL_DIR)/scripts/setup/server_setup.sh /usr/local/bin/server-setup
	@echo "Instalação concluída!"

# Testes
test:
	@echo "Executando testes..."
	./tests/test_runner.sh

# Verificação de qualidade
lint:
	@echo "Verificando qualidade do código..."
	find scripts/ -name "*.sh" -exec shellcheck {} \;

# Limpeza
clean:
	@echo "Limpando arquivos temporários..."
	find . -name "*.tmp" -delete
	find . -name "*.log" -delete

# Backup
backup:
	@echo "Fazendo backup das configurações..."
	tar -czf backup-$(shell date +%Y%m%d_%H%M%S).tar.gz configs/ scripts/

# Configurar ambiente de desenvolvimento
setup-dev:
	@echo "Configurando ambiente de desenvolvimento..."
	sudo apt update
	sudo apt install -y shellcheck yamllint
	pip3 install pre-commit
	pre-commit install