#!/bin/bash
# scripts/seguranca/clamscan_daily.sh
# Descrição: Varredura ClamAV - Diária Otimizada
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# CONFIGURAÇÕES
# ═══════════════════════════════════════════════════════════════

LOG_DIR="/var/log/clamav"
LOG_FILE="$LOG_DIR/clamscan_$(date +%F).log"
LOCK_FILE="/var/run/clamav-scan.lock"
TIMEOUT=7200  # 2 horas
EMAIL=""  # Configure seu email aqui (opcional)

# ═══════════════════════════════════════════════════════════════
# FUNÇÕES
# ═══════════════════════════════════════════════════════════════

log() {
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] $1" | tee -a "$LOG_FILE"
}

info() {
    log "ℹ️  $1"
}

success() {
    log "✅ $1"
}

warning() {
    log "⚠️  $1"
}

error() {
    log "❌ ERRO: $1"
}

die() {
    error "$1"
    cleanup
    exit 1
}

cleanup() {
    [[ -f "$LOCK_FILE" ]] && rm -f "$LOCK_FILE"
}

# Trap para cleanup em caso de interrupção
trap cleanup EXIT INT TERM

# ═══════════════════════════════════════════════════════════════
# VERIFICAÇÕES ESSENCIAIS
# ═══════════════════════════════════════════════════════════════

check_lock() {
    # Verifica se há outra instância rodando
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(<"$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            die "Outra instância já está rodando (PID: $pid)"
        else
            warning "Lock file órfão encontrado, removendo..."
            rm -f "$LOCK_FILE"
        fi
    fi
}

setup_logging() {
    # Cria diretório de logs se não existir
    mkdir -p "$LOG_DIR"
    chown clamav:adm "$LOG_DIR" 2>/dev/null || true
    chmod 755 "$LOG_DIR"
}

run_scan() {
    info "Iniciando varredura completa do sistema..."
    
    # Cria lock file
    echo $$ > "$LOCK_FILE"
    
    # Executa varredura com timeout
    local scan_result=0
    
    if timeout $TIMEOUT clamscan -r -i \
        --exclude-dir="^/(sys|proc|dev|run|mnt|media|snap|tmp|var/tmp|var/cache)" \
        / >> "$LOG_FILE" 2>&1; then
        success "Varredura concluída com sucesso"
    else
        scan_result=$?
        case $scan_result in
            1)
                warning "Varredura concluída com ameaças encontradas"
                ;;
            124)
                error "Varredura interrompida por timeout ($TIMEOUT segundos)"
                ;;
            *)
                error "Varredura falhou com código de saída: $scan_result"
                ;;
        esac
    fi
    
    return $scan_result
}

process_results() {
    info "Processando resultados da varredura..."
    
    # Verifica se ameaças foram encontradas
    if grep -q "FOUND" "$LOG_FILE"; then
        local infected_count
        infected_count=$(grep -c "FOUND" "$LOG_FILE")
        warning "$infected_count ameaça(s) detectada(s)!"
        
        # Lista ameaças encontradas
        info "Ameaças detectadas:"
        grep "FOUND" "$LOG_FILE" | while read -r line; do
            warning "$line"
        done
        
        # Envia email de alerta (se configurado)
        if [[ -n "$EMAIL" ]] && command -v mail >/dev/null 2>&1; then
            {
                echo "⚠️ ALERTA DE SEGURANÇA - ClamAV"
                echo "Servidor: $(hostname)"
                echo "Data: $(date)"
                echo "Ameaças encontradas: $infected_count"
                echo ""
                echo "Detalhes:"
                grep "FOUND" "$LOG_FILE"
                echo ""
                echo "Log completo em: $LOG_FILE"
            } | mail -s "⚠️ ClamAV: $infected_count ameaça(s) em $(hostname)" "$EMAIL"
            
            info "Email de alerta enviado para $EMAIL"
        fi
    else
        success "Nenhuma ameaça detectada"
    fi
    
    # Estatísticas da varredura
    if grep -q "Scanned files:" "$LOG_FILE"; then
        local scanned_files
        scanned_files=$(grep "Scanned files:" "$LOG_FILE" | tail -1 | awk '{print $3}')
        info "Arquivos verificados: $scanned_files"
    fi
    
    # Define permissões do log
    chmod 640 "$LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════
# EXECUÇÃO PRINCIPAL
# ═══════════════════════════════════════════════════════════════

main() {
    info "═══════════════════════════════════════════════════════════════"
    info "Iniciando Varredura ClamAV - $(date)"
    info "═══════════════════════════════════════════════════════════════"
    
    check_lock
    setup_logging
    
    local scan_exit_code=0
    if ! run_scan; then
        scan_exit_code=$?
    fi
    
    process_results
    
    info "═══════════════════════════════════════════════════════════════"
    info "Varredura finalizada - $(date)"
    info "Log salvo em: $LOG_FILE"
    info "═══════════════════════════════════════════════════════════════"
    
    return $scan_exit_code
}

# Executa apenas se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

