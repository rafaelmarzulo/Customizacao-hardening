#!/bin/bash
# scripts/hardening/ssh_hardening.sh
# Descrição: Script para hardening do SSH
# Autor: Rafael Marzulo
# Versão: 2.0.1
# Data: 10/07/2025

set -euo pipefail

# Ajuda
if [[ "${1:-}" == "--help" ]]; then
  echo "🛡️  Script de Hardening SSH"
  echo "Uso: $0 [--help]"
  echo
  echo "Este script aplica configurações seguras ao serviço SSH usando um template definido."
  echo
  echo "Opções:"
  echo "  --help         Exibe esta mensagem de ajuda"
  exit 0
fi

# Detectar modo de execução: instalado ou local
if [[ -d "/opt/customizacao-hardening/scripts/utils" ]]; then
  # 🏁 Modo instalado
  UTILS_DIR="/opt/customizacao-hardening/scripts/utils"
  CONFIG_DIR="/etc/customizacao-hardening"
else
  # 🧪 Modo desenvolvimento (execução direta)
  readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  UTILS_DIR="$PROJECT_ROOT/scripts/utils"
  CONFIG_DIR="$PROJECT_ROOT/configs/ssh"
fi

# Importar bibliotecas
source "$UTILS_DIR/logger.sh"
source "$UTILS_DIR/validator.sh"
source "$UTILS_DIR/backup.sh"

# Configuração SSH
readonly SSHD_CONFIG="/etc/ssh/sshd_config"
readonly SSH_CONFIG_TEMPLATE="$CONFIG_DIR/sshd_config.template"

# Exemplo de uso do logger e validação
log_info "Iniciando hardening do SSH..."

# Valida se a template existe
validate_file "$SSH_CONFIG_TEMPLATE"

# Faz backup e substitui
backup_file "$SSHD_CONFIG"
cp "$SSH_CONFIG_TEMPLATE" "$SSHD_CONFIG"

log_success "Configuração SSH aplicada com sucesso."

echo "Deseja reiniciar o SSH agora? (s/n)"
read -r resp
if [[ "$resp" =~ ^[sS]$ ]]; then
  systemctl restart ssh || systemctl restart sshd
  log_info "Serviço SSH reiniciado."
else
  log_warn "⚠️ Lembre-se de reiniciar o serviço SSH manualmente."
fi
