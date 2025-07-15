# Makefile para automação do projeto Customização e Hardening

.PHONY: help install test lint clean backup setup-dev status run-all configure

# Variáveis
PROJECT_NAME := customizacao-hardening
INSTALL_DIR := /opt/$(PROJECT_NAME)
CONFIG_DIR := /etc/$(PROJECT_NAME)
LOG_DIR := /var/log/$(PROJECT_NAME)

# Ajuda melhorada
help:
	@echo "🛡️ Customização e Hardening - Comandos Disponíveis:"
	@echo ""
	@echo "📦 INSTALAÇÃO:"
	@echo "  install     - Instalar scripts no sistema"
	@echo "  setup-dev   - Configurar ambiente de desenvolvimento"
	@echo ""
	@echo "🚀 EXECUÇÃO:"
	@echo "  run-all     - Executar hardening completo (CUIDADO!)"
	@echo "  configure   - Configuração interativa"
	@echo ""
	@echo "🧪 TESTES:"
	@echo "  test        - Executar testes"
	@echo "  test-dev    - Testar execução direta dos scripts"
	@echo "  lint        - Verificar qualidade do código"
	@echo ""
	@echo "📊 MONITORAMENTO:"
	@echo "  status      - Ver status do sistema"
	@echo "  backup      - Fazer backup das configurações"
	@echo ""
	@echo "🛠️ MANUTENÇÃO:"
	@echo "  clean       - Limpar arquivos temporários"
	@echo ""
	@echo "💡 EXEMPLOS DE USO:"
	@echo "  sudo make install && sudo ssh_hardening"
	@echo "  make test-dev"
	@echo "  make status"

# Instalação
install:
	@echo "📦 Instalando $(PROJECT_NAME)..."
	sudo mkdir -p $(INSTALL_DIR) $(CONFIG_DIR) $(LOG_DIR)
	sudo cp -r scripts/ Makefile config.yaml $(INSTALL_DIR)/
	[ -d configs/ ] && sudo cp -r configs/ $(CONFIG_DIR)/ || true
	sudo chmod +x $(INSTALL_DIR)/scripts/*/*.sh
	sudo ln -sf $(INSTALL_DIR)/scripts/hardening/ssh_hardening.sh /usr/local/bin/ssh_hardening
	sudo ln -sf $(INSTALL_DIR)/scripts/setup/server_setup.sh /usr/local/bin/server_setup
	sudo ln -sf $(INSTALL_DIR)/scripts/hardening/firewall_setup.sh /usr/local/bin/firewall_setup
	sudo ln -sf $(INSTALL_DIR)/scripts/security/clamav_setup.sh /usr/local/bin/clamav_setup
	@echo "✅ Instalação concluída!"
	@echo "💡 Execute 'make help' para ver comandos disponíveis"

# Testes
test:
	@echo "🧪 Executando testes..."
	./tests/test_runner.sh

# Verificação de qualidade
lint:
	@echo "🔍 Verificando qualidade do código..."
	find scripts/ -name "*.sh" -exec shellcheck {} \;

# Limpeza
clean:
	@echo "🧹 Limpando arquivos temporários..."
	find . -name "*.tmp" -delete
	find . -name "*.log" -delete

# Backup
backup:
	@echo "💾 Fazendo backup das configurações..."
	tar -czf backup-$(shell date +%Y%m%d_%H%M%S).tar.gz configs/ scripts/

# Configurar ambiente de desenvolvimento
setup-dev:
	@echo "⚙️ Configurando ambiente de desenvolvimento..."
	sudo apt update
	sudo apt install -y shellcheck yamllint
	pip3 install pre-commit
	pre-commit install

# Status do sistema
status:
	@echo "📊 Status do Sistema de Hardening:"
	@echo "=================================="
	@echo "SSH Service: $$(systemctl is-active ssh 2>/dev/null || echo 'N/A')"
	@echo "UFW Firewall: $$(systemctl is-active ufw 2>/dev/null || echo 'N/A')"
	@echo "ClamAV: $$(systemctl is-active clamav-daemon 2>/dev/null || echo 'N/A')"
	@echo "Fail2Ban: $$(systemctl is-active fail2ban 2>/dev/null || echo 'N/A')"
	@echo ""
	@echo "📁 Arquivos de Log:"
	@ls -la $(LOG_DIR) 2>/dev/null || echo "Diretório de logs não encontrado"
	@echo ""
	@echo "⚙️ Scripts Instalados:"
	@ls -la /usr/local/bin/ | grep -E "(ssh_hardening|server_setup|firewall_setup|clamav_setup)" || echo "Scripts não encontrados em /usr/local/bin/"
	@echo ""
	@echo "🔧 Configurações:"
	@ls -la $(CONFIG_DIR) 2>/dev/null || echo "Diretório de configurações não encontrado"

# Execução completa com confirmação
run-all:
	@echo "🚀 EXECUÇÃO COMPLETA DO HARDENING"
	@echo "================================="
	@echo "⚠️  ATENÇÃO: Isso modificará configurações críticas do sistema!"
	@echo "📋 Scripts que serão executados:"
	@echo "   1. server_setup.sh - Configuração inicial"
	@echo "   2. ssh_hardening.sh - Hardening SSH"
	@echo "   3. firewall_setup.sh - Configuração firewall"
	@echo "   4. clamav_setup.sh - Instalação antivírus"
	@echo ""
	@read -p "🤔 Tem certeza que deseja continuar? (digite 'SIM' para confirmar): " confirm && [ "$$confirm" = "SIM" ]
	@echo "🔄 Iniciando hardening..."
	sudo $(INSTALL_DIR)/scripts/setup/server_setup.sh
	sudo $(INSTALL_DIR)/scripts/hardening/ssh_hardening.sh
	sudo $(INSTALL_DIR)/scripts/hardening/firewall_setup.sh
	sudo $(INSTALL_DIR)/scripts/security/clamav_setup.sh
	@echo "✅ Hardening completo concluído!"
	@echo "📊 Execute 'make status' para verificar o resultado"

# Configuração interativa
configure:
	@echo "⚙️ Configuração interativa..."
	@if [ -f config.yaml ]; then \
		nano config.yaml; \
		echo "✅ Configuração atualizada!"; \
	else \
		echo "❌ Arquivo config.yaml não encontrado!"; \
		exit 1; \
	fi

# Teste de execução direta dos scripts no modo desenvolvimento
test-dev:
	@echo "🧪 Testando execução direta dos scripts (modo desenvolvimento)..."
	@echo ""
	@echo "🔧 Testando: scripts/hardening/ssh_hardening.sh"
	@bash scripts/hardening/ssh_hardening.sh --help || echo "⚠️ Ignorando erro esperado"
	@echo ""
	@echo "🔧 Testando: scripts/setup/server_setup.sh"
	@bash scripts/setup/server_setup.sh --help || echo "⚠️ Ignorando erro esperado"
	@echo ""
	@echo "✅ Teste de execução direta concluído!"

# Verificar se sistema está pronto para hardening
check-system:
	@echo "🔍 Verificando sistema..."
	@echo "OS: $$(lsb_release -d 2>/dev/null | cut -f2 || echo 'Desconhecido')"
	@echo "Kernel: $$(uname -r)"
	@echo "Usuário: $$(whoami)"
	@echo "Sudo: $$(sudo -n true 2>/dev/null && echo 'OK' || echo 'Necessário')"
	@echo "Conectividade: $$(ping -c1 8.8.8.8 >/dev/null 2>&1 && echo 'OK' || echo 'Sem internet')"

# Desinstalar
uninstall:
	@echo "🗑️ Desinstalando $(PROJECT_NAME)..."
	@read -p "🤔 Tem certeza que deseja desinstalar? (y/N): " confirm && [ "$$confirm" = "y" ]
	sudo rm -rf $(INSTALL_DIR)
	sudo rm -rf $(CONFIG_DIR)
	sudo rm -f /usr/local/bin/ssh_hardening
	sudo rm -f /usr/local/bin/server_setup
	sudo rm -f /usr/local/bin/firewall_setup
	sudo rm -f /usr/local/bin/clamav_setup
	@echo "✅ Desinstalação concluída!"
	@echo "⚠️ Logs mantidos em $(LOG_DIR)"

