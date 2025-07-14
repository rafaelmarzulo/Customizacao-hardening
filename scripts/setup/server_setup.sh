#!/bin/bash
# scripts/setup/server_setup.sh
# Descrição: Script de configuração inicial do servidor
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 10/07/2025

set -euo pipefail

# Ajuda
if [[ "${1:-}" == "--help" ]]; then
  echo "⚙️  Script de Configuração Inicial do Servidor"
  echo "Uso: $0 [--help]"
  echo
  echo "Este script aplica configurações iniciais como porta SSH, autenticação e permissões"
  echo "com base no arquivo config.yaml."
  echo
  echo "Opções:"
  echo "  --help         Exibe esta mensagem de ajuda"
  exit 0
fi

# Detectar modo de execução: instalado ou local
if [[ -d "/opt/customizacao-hardening/scripts/utils" ]]; then
  # 🏁 Modo instalado
  UTILS_DIR="/opt/customizacao-hardening/scripts/utils"
  CONFIG_PATH="/etc/customizacao-hardening/config.yaml"
else
  # 🧪 Modo desenvolvimento (execução direta)
  readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  UTILS_DIR="$PROJECT_ROOT/scripts/utils"
  CONFIG_PATH="$PROJECT_ROOT/config.yaml"
fi

# Importar bibliotecas
source "$UTILS_DIR/logger.sh"
source "$UTILS_DIR/validator.sh"

# Validação do config.yaml
validate_file "$CONFIG_PATH"

# Exemplo de leitura da configuração com yq (verifique se o yq está instalado!)
if ! command -v yq &>/dev/null; then
  log_error "yq não está instalado. Instale com: sudo apt install yq"
  exit 1
fi

log_info "Carregando configurações do arquivo: $CONFIG_PATH"

PROJECT_NAME=$(yq '.project.name' "$CONFIG_PATH")
SSH_PORT=$(yq '.ssh.port' "$CONFIG_PATH")
ALLOW_ROOT=$(yq '.ssh.allow_root' "$CONFIG_PATH")
PASSWORD_AUTH=$(yq '.ssh.password_auth' "$CONFIG_PATH")

log_info "Projeto: $PROJECT_NAME"
log_info "Porta SSH: $SSH_PORT"
log_info "Permitir Root: $ALLOW_ROOT"
log_info "Autenticação por senha: $PASSWORD_AUTH"

# Exemplo: ajustes que podem ser aplicados
log_info "Aplicando configurações iniciais do servidor..."

# Aqui você pode incluir comandos reais de setup (firewall, updates etc)

log_success "Configuração inicial concluída com sucesso!"
