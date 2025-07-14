#!/bin/bash
# scripts/utils/logger.sh
# Descrição: Sistema de logging centralizado
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025


# Configurações globais
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[1]}")"
readonly LOG_DIR="${LOG_DIR:-/var/log/hardening}"
readonly LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.*}.log"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Níveis de log
readonly LOG_LEVELS=(DEBUG INFO WARN ERROR FATAL)

# Função para verificar se o nível de log é válido
is_log_level_enabled() {
    local level="$1"
    local current_level_index
    local target_level_index
    
    for i in "${!LOG_LEVELS[@]}"; do
        [[ "${LOG_LEVELS[$i]}" == "$LOG_LEVEL" ]] && current_level_index=$i
        [[ "${LOG_LEVELS[$i]}" == "$level" ]] && target_level_index=$i
    done
    
    [[ $target_level_index -ge $current_level_index ]]
}

# Função de log genérica
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${BASH_SOURCE[2]##*/}:${BASH_LINENO[1]}"
    
    # Verificar se o nível está habilitado
    is_log_level_enabled "$level" || return 0
    
    # Criar diretório de log se não existir
    [[ ! -d "$LOG_DIR" ]] && mkdir -p "$LOG_DIR"
    
    # Escrever no arquivo de log
    echo "[$timestamp] [$level] [$caller] $message" >> "$LOG_FILE"
    
    # Output colorido no terminal
    case "$level" in
        DEBUG) echo -e "${PURPLE}🔍 DEBUG:${NC} $message" ;;
        INFO)  echo -e "${BLUE}ℹ️  INFO:${NC} $message" ;;
        WARN)  echo -e "${YELLOW}⚠️  WARN:${NC} $message" ;;
        ERROR) echo -e "${RED}❌ ERROR:${NC} $message" >&2 ;;
        FATAL) echo -e "${RED}💀 FATAL:${NC} $message" >&2 ;;
    esac
}

# Funções específicas
debug() { log "DEBUG" "$@"; }
info() { log "INFO" "$@"; }
warn() { log "WARN" "$@"; }
error() { log "ERROR" "$@"; }
fatal() { log "FATAL" "$@"; exit 1; }

# Função para log de sucesso
success() {
    log "INFO" "SUCCESS: $*"
    echo -e "${GREEN}✅ SUCCESS:${NC} $*"
}

# Função para mostrar progresso
progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    local percent=$((current * 100 / total))
    
    printf "\r${CYAN}⏳ Progress:${NC} [%3d%%] %s" "$percent" "$message"
    [[ $current -eq $total ]] && echo
}