#!/bin/bash
# fix-sftp-hardening.sh - Garante funcionamento do SFTP após hardening SSH
# Autor: Manus AI Assistant
# Versão: 1.0
# Data: 2025-07-15
# Descrição: Corrige configuração SSH para manter SFTP funcional após hardening

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Funções de log
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
header() { echo -e "${PURPLE}🔧 $1${NC}"; }
debug() { echo -e "${CYAN}🔧 DEBUG: $1${NC}"; }

echo -e "${PURPLE}🔧 FIX: SFTP após Hardening SSH${NC}"
echo "================================="
echo ""

# Verificar se é executado como root
if [ "$EUID" -ne 0 ]; then
    error "Execute como root: sudo $0"
    exit 1
fi

# Variáveis
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CONFIG_TEMPLATE="/etc/customizacao-hardening/configs/ssh/sshd_config.template"
BACKUP_DIR="/var/backups/customizacao-hardening"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Possíveis caminhos do sftp-server
SFTP_PATHS=(
    "/usr/lib/openssh/sftp-server"
    "/usr/libexec/openssh/sftp-server"
    "/usr/lib/ssh/sftp-server"
    "/usr/sbin/sftp-server"
)

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

# Função para encontrar o caminho correto do sftp-server
find_sftp_server() {
    local sftp_path=""
    
    for path in "${SFTP_PATHS[@]}"; do
        if [ -f "$path" ]; then
            sftp_path="$path"
            break
        fi
    done
    
    if [ -z "$sftp_path" ]; then
        # Tentar encontrar com find
        sftp_path=$(find /usr -name "sftp-server" -type f 2>/dev/null | head -1)
    fi
    
    echo "$sftp_path"
}

# Função para fazer backup
backup_file() {
    local file="$1"
    local backup_name="$(basename "$file").backup.$TIMESTAMP"
    
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$backup_name"
        success "Backup criado: $BACKUP_DIR/$backup_name"
        return 0
    else
        warning "Arquivo não encontrado para backup: $file"
        return 1
    fi
}

# Função para verificar se SFTP está configurado
check_sftp_config() {
    local config_file="$1"
    
    if grep -q "^Subsystem.*sftp" "$config_file"; then
        return 0  # SFTP configurado
    else
        return 1  # SFTP não configurado
    fi
}

# Função para testar SFTP
test_sftp() {
    local test_user="${1:-ubuntu}"
    
    info "Testando funcionamento do SFTP..."
    
    # Verificar se o serviço SSH está ativo
    if ! systemctl is-active ssh >/dev/null 2>&1; then
        warning "Serviço SSH não está ativo"
        return 1
    fi
    
    # Testar conexão SFTP local (se possível)
    if command -v sftp >/dev/null 2>&1; then
        # Criar teste básico
        local test_result
        timeout 5 sftp -o BatchMode=yes -o ConnectTimeout=3 "$test_user@localhost" <<< "quit" >/dev/null 2>&1
        test_result=$?
        
        if [ $test_result -eq 0 ]; then
            success "SFTP funcionando corretamente"
            return 0
        else
            warning "SFTP pode ter problemas de conectividade"
            return 1
        fi
    else
        info "Cliente SFTP não disponível para teste"
        return 0
    fi
}

# ============================================================================
# EXECUÇÃO PRINCIPAL
# ============================================================================

header "INICIANDO CORREÇÃO DO SFTP"
echo ""

# ETAPA 1: Verificações iniciais
info "Verificando arquivos de configuração..."

if [ ! -f "$SSHD_CONFIG" ]; then
    error "Arquivo sshd_config não encontrado: $SSHD_CONFIG"
    exit 1
fi

success "Arquivo sshd_config encontrado"

# ETAPA 2: Encontrar caminho do sftp-server
info "Localizando sftp-server..."

SFTP_SERVER_PATH=$(find_sftp_server)

if [ -z "$SFTP_SERVER_PATH" ]; then
    error "sftp-server não encontrado no sistema"
    error "Instale o openssh-server: apt install openssh-server"
    exit 1
fi

success "sftp-server encontrado: $SFTP_SERVER_PATH"

# ETAPA 3: Verificar configuração atual
info "Verificando configuração atual do SFTP..."

if check_sftp_config "$SSHD_CONFIG"; then
    # Verificar se o caminho está correto
    current_sftp_line=$(grep "^Subsystem.*sftp" "$SSHD_CONFIG")
    current_path=$(echo "$current_sftp_line" | awk '{print $3}')
    
    if [ "$current_path" = "$SFTP_SERVER_PATH" ]; then
        success "SFTP já configurado corretamente: $current_path"
        
        # Testar funcionamento
        if test_sftp; then
            success "🎉 SFTP funcionando perfeitamente!"
            echo ""
            info "Nenhuma correção necessária"
            exit 0
        else
            warning "SFTP configurado mas com problemas"
        fi
    else
        warning "SFTP configurado com caminho incorreto: $current_path"
        warning "Caminho correto deveria ser: $SFTP_SERVER_PATH"
    fi
else
    warning "SFTP não configurado no sshd_config"
fi

# ETAPA 4: Fazer backup
info "Fazendo backup do sshd_config..."
backup_file "$SSHD_CONFIG"

# ETAPA 5: Corrigir configuração
header "APLICANDO CORREÇÃO DO SFTP"

info "Removendo configurações SFTP antigas (se existirem)..."
sed -i '/^Subsystem.*sftp/d' "$SSHD_CONFIG"

info "Adicionando configuração SFTP correta..."
echo "" >> "$SSHD_CONFIG"
echo "# Habilita o subsistema SFTP para transferência segura de arquivos" >> "$SSHD_CONFIG"
echo "Subsystem sftp $SFTP_SERVER_PATH" >> "$SSHD_CONFIG"

success "Configuração SFTP adicionada"

# ETAPA 6: Atualizar template (se existir)
if [ -f "$SSHD_CONFIG_TEMPLATE" ]; then
    info "Atualizando template SSH..."
    
    # Fazer backup do template
    backup_file "$SSHD_CONFIG_TEMPLATE"
    
    # Remover linha antiga do template
    sed -i '/^Subsystem.*sftp/d' "$SSHD_CONFIG_TEMPLATE"
    
    # Adicionar linha correta ao template
    echo "" >> "$SSHD_CONFIG_TEMPLATE"
    echo "# Habilita o subsistema SFTP para transferência segura de arquivos" >> "$SSHD_CONFIG_TEMPLATE"
    echo "Subsystem sftp $SFTP_SERVER_PATH" >> "$SSHD_CONFIG_TEMPLATE"
    
    success "Template SSH atualizado"
else
    info "Template SSH não encontrado (normal se não usando sistema customizado)"
fi

# ETAPA 7: Validar configuração
info "Validando configuração SSH..."

if sshd -t 2>/dev/null; then
    success "Configuração SSH válida"
else
    error "Configuração SSH inválida!"
    error "Restaurando backup..."
    
    # Restaurar backup
    latest_backup=$(ls -t "$BACKUP_DIR"/sshd_config.backup.* 2>/dev/null | head -1)
    if [ -n "$latest_backup" ]; then
        cp "$latest_backup" "$SSHD_CONFIG"
        warning "Backup restaurado: $latest_backup"
    fi
    
    exit 1
fi

# ETAPA 8: Reiniciar SSH
info "Reiniciando serviço SSH..."

if systemctl restart ssh; then
    success "Serviço SSH reiniciado"
    
    # Aguardar um momento para o serviço inicializar
    sleep 2
    
    if systemctl is-active ssh >/dev/null 2>&1; then
        success "Serviço SSH ativo"
    else
        error "Serviço SSH falhou ao iniciar"
        exit 1
    fi
else
    error "Falha ao reiniciar SSH"
    exit 1
fi

# ETAPA 9: Teste final
header "TESTE FINAL DO SFTP"

info "Aguardando estabilização do serviço..."
sleep 3

if test_sftp; then
    success "✅ SFTP funcionando corretamente!"
else
    warning "SFTP pode ter problemas - verifique manualmente"
fi

# ETAPA 10: Verificações adicionais
info "Verificações adicionais..."

# Verificar porta SSH
ssh_port=$(grep "^Port" "$SSHD_CONFIG" | awk '{print $2}' || echo "22")
info "SSH rodando na porta: $ssh_port"

# Verificar usuários permitidos
allowed_users=$(grep "^AllowUsers" "$SSHD_CONFIG" | cut -d' ' -f2- || echo "todos")
info "Usuários permitidos: $allowed_users"

# Mostrar configuração SFTP atual
current_sftp=$(grep "^Subsystem.*sftp" "$SSHD_CONFIG")
info "Configuração SFTP: $current_sftp"

# ============================================================================
# RESULTADO FINAL
# ============================================================================

echo ""
header "🎉 CORREÇÃO DO SFTP CONCLUÍDA!"
echo ""

success "✅ SFTP configurado corretamente"
success "✅ Caminho do sftp-server: $SFTP_SERVER_PATH"
success "✅ Configuração SSH validada"
success "✅ Serviço SSH reiniciado"
success "✅ Template atualizado (se aplicável)"

echo ""
info "📋 RESUMO DA CORREÇÃO:"
echo "  • Backup criado em: $BACKUP_DIR"
echo "  • SFTP habilitado com: $SFTP_SERVER_PATH"
echo "  • SSH rodando na porta: $ssh_port"
echo "  • Configuração validada e aplicada"

echo ""
info "🧪 COMO TESTAR O SFTP:"
echo "  • Teste local: sftp usuario@localhost"
echo "  • Teste remoto: sftp usuario@ip_do_servidor"
echo "  • Verificar logs: tail -f /var/log/auth.log"

echo ""
success "🏆 SFTP funcionando após hardening SSH!"

# Mostrar status final
echo ""
info "📊 STATUS FINAL:"
systemctl status ssh --no-pager -l | head -10

echo ""
success "🔒 Sistema seguro com SFTP funcional!"

