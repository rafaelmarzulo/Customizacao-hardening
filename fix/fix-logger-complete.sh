#!/bin/bash
# fix-logger-complete.sh - Correção completa do logger.sh

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funções de log
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

echo -e "${BLUE}🔧 CORREÇÃO COMPLETA DO LOGGER${NC}"
echo "==============================="
echo ""

# Verificar se está executando como root
if [ "$EUID" -ne 0 ]; then
    error "Execute como root: sudo $0"
    exit 1
fi

# Verificar se o arquivo existe
LOGGER_FILE="/opt/customizacao-hardening/scripts/utils/logger.sh"
if [ ! -f "$LOGGER_FILE" ]; then
    error "Arquivo logger não encontrado: $LOGGER_FILE"
    exit 1
fi

echo "📋 ETAPA 1: Analisando problemas do logger"
echo "=========================================="

info "Verificando problemas no logger atual..."
if grep -n "readonly" "$LOGGER_FILE"; then
    warning "Variáveis readonly encontradas que podem causar conflitos"
else
    info "Nenhuma variável readonly encontrada"
fi

echo ""
echo "📋 ETAPA 2: Fazendo backup e aplicando correção completa"
echo "========================================================"

info "Fazendo backup do logger atual..."
cp "$LOGGER_FILE" "${LOGGER_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

info "Criando novo logger corrigido..."

# Criar novo logger sem conflitos de variáveis readonly
cat > "$LOGGER_FILE" << 'EOF'
#!/bin/bash
# logger.sh - Sistema de logging melhorado e sem conflitos

# Verificar e definir variáveis apenas se não existirem
[ -z "${SCRIPT_NAME:-}" ] && SCRIPT_NAME=$(basename "${0}")
[ -z "${LOG_DIR:-}" ] && LOG_DIR="/var/log/customizacao-hardening"
[ -z "${LOG_FILE:-}" ] && LOG_FILE="${LOG_DIR}/hardening.log"

# Criar diretório de log se não existir
mkdir -p "$LOG_DIR" 2>/dev/null || true

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função de log genérica
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log para arquivo
    echo "[$timestamp] [$level] [$SCRIPT_NAME] $message" >> "$LOG_FILE" 2>/dev/null || true
    
    # Log para console com cores
    case "$level" in
        "INFO")
            echo -e "${BLUE}ℹ️  INFO: $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ SUCCESS: $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ ERROR: $message${NC}"
            ;;
        *)
            echo -e "${NC}$message${NC}"
            ;;
    esac
}

# Funções específicas de log
log_info() {
    log_message "INFO" "$1"
}

log_success() {
    log_message "SUCCESS" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

# Função de validação de arquivos
validate_file() {
    local file="$1"
    local description="${2:-arquivo}"
    
    if [ ! -f "$file" ]; then
        log_error "$description não encontrado: $file"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        log_error "$description não é legível: $file"
        return 1
    fi
    
    log_info "$description validado: $file"
    return 0
}

# Função de validação de diretórios
validate_directory() {
    local dir="$1"
    local description="${2:-diretório}"
    
    if [ ! -d "$dir" ]; then
        log_error "$description não encontrado: $dir"
        return 1
    fi
    
    if [ ! -r "$dir" ]; then
        log_error "$description não é legível: $dir"
        return 1
    fi
    
    log_info "$description validado: $dir"
    return 0
}

# Função para verificar se comando existe
command_exists() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        log_info "Comando '$cmd' encontrado"
        return 0
    else
        log_error "Comando '$cmd' não encontrado"
        return 1
    fi
}

# Função para executar comando com log
execute_with_log() {
    local cmd="$1"
    local description="${2:-comando}"
    
    log_info "Executando: $description"
    
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log_success "$description executado com sucesso"
        return 0
    else
        log_error "Falha ao executar: $description"
        return 1
    fi
}

# Inicializar log
log_info "Logger inicializado para script: $SCRIPT_NAME"
EOF

# Tornar o arquivo executável
chmod +x "$LOGGER_FILE"

success "Novo logger criado com sucesso!"

echo ""
echo "📋 ETAPA 3: Testando novo logger"
echo "==============================="

info "Testando funções do logger..."

# Testar se o logger funciona
if source "$LOGGER_FILE" 2>/dev/null; then
    success "Logger carregado com sucesso!"
    
    # Testar funções
    log_info "Teste da função log_info"
    log_success "Teste da função log_success"
    log_warning "Teste da função log_warning"
    
else
    error "Falha ao carregar novo logger"
    exit 1
fi

echo ""
echo "📋 ETAPA 4: Testando scripts principais"
echo "======================================="

info "Testando server-setup..."
if timeout 10 server-setup --help >/dev/null 2>&1; then
    success "server-setup funcionando!"
else
    warning "server-setup ainda com problemas"
fi

info "Testando ssh-hardening..."
if timeout 10 ssh-hardening --help >/dev/null 2>&1; then
    success "ssh-hardening funcionando!"
else
    warning "ssh-hardening ainda com problemas"
fi

echo ""
echo "📋 ETAPA 5: Teste de execução real"
echo "=================================="

warning "Vamos testar a execução real dos scripts..."
read -p "Deseja executar server-setup agora? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Executando server-setup..."
    if server-setup; then
        success "server-setup executado com sucesso!"
    else
        error "server-setup falhou"
    fi
else
    info "Teste de server-setup pulado"
fi

echo ""
echo "🎉 CORREÇÃO COMPLETA DO LOGGER FINALIZADA!"
echo "=========================================="
echo ""
echo "✅ Correções aplicadas:"
echo "  - Novo logger sem conflitos de variáveis readonly"
echo "  - Funções de log melhoradas"
echo "  - Validação de arquivos e diretórios"
echo "  - Sistema de cores aprimorado"
echo "  - Logging para arquivo e console"
echo ""
echo "🔧 Funcionalidades do novo logger:"
echo "  - log_info(), log_success(), log_warning(), log_error()"
echo "  - validate_file(), validate_directory()"
echo "  - command_exists(), execute_with_log()"
echo ""
echo "📁 Arquivos:"
echo "  - Logger atual: $LOGGER_FILE"
echo "  - Backup: ${LOGGER_FILE}.backup.*"
echo "  - Log file: $LOG_FILE"
echo ""
echo "🚀 Próximos passos:"
echo "  1. Testar: sudo server-setup"
echo "  2. Aplicar: sudo ssh-hardening"
echo "  3. Verificar: make status"
echo ""
success "Logger enterprise-grade implementado! 🏆"

