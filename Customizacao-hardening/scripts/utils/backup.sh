#!/bin/bash
# scripts/utils/backup.sh
# Descrição: Sistema de backup automatizado
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025

set -euo pipefail


source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

readonly BACKUP_BASE_DIR="${BACKUP_BASE_DIR:-/var/backups/hardening}"
readonly BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

# Criar backup de arquivo
backup_file() {
    local source_file="$1"
    local backup_name="${2:-$(basename "$source_file")}"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_dir="$BACKUP_BASE_DIR/$(date '+%Y/%m/%d')"
    local backup_file="$backup_dir/${backup_name}.${timestamp}.bak"
    
    # Validações
    [[ -z "$source_file" ]] && fatal "Arquivo de origem não especificado"
    [[ ! -f "$source_file" ]] && fatal "Arquivo não encontrado: $source_file"
    
    # Criar diretório de backup
    mkdir -p "$backup_dir" || fatal "Falha ao criar diretório de backup: $backup_dir"
    
    # Fazer backup
    if cp "$source_file" "$backup_file"; then
        success "Backup criado: $backup_file"
        
        # Calcular e armazenar checksum
        local checksum=$(sha256sum "$backup_file" | cut -d' ' -f1)
        echo "$checksum  $backup_file" > "${backup_file}.sha256"
        
        # Retornar caminho do backup
        echo "$backup_file"
    else
        fatal "Falha ao criar backup de: $source_file"
    fi
}

# Restaurar backup
restore_backup() {
    local backup_file="$1"
    local target_file="$2"
    
    # Validações
    [[ -z "$backup_file" ]] && fatal "Arquivo de backup não especificado"
    [[ ! -f "$backup_file" ]] && fatal "Backup não encontrado: $backup_file"
    [[ -z "$target_file" ]] && fatal "Arquivo de destino não especificado"
    
    # Verificar checksum se disponível
    if [[ -f "${backup_file}.sha256" ]]; then
        info "Verificando integridade do backup..."
        if ! sha256sum -c "${backup_file}.sha256" &>/dev/null; then
            fatal "Backup corrompido: $backup_file"
        fi
        success "Integridade do backup verificada"
    fi
    
    # Fazer backup do arquivo atual se existir
    if [[ -f "$target_file" ]]; then
        local current_backup
        current_backup=$(backup_file "$target_file" "$(basename "$target_file").pre-restore")
        info "Backup do arquivo atual criado: $current_backup"
    fi
    
    # Restaurar
    if cp "$backup_file" "$target_file"; then
        success "Backup restaurado: $backup_file -> $target_file"
    else
        fatal "Falha ao restaurar backup: $backup_file"
    fi
}

# Listar backups disponíveis
list_backups() {
    local file_pattern="$1"
    
    if [[ -d "$BACKUP_BASE_DIR" ]]; then
        find "$BACKUP_BASE_DIR" -name "*${file_pattern}*.bak" -type f | sort
    else
        warn "Diretório de backup não encontrado: $BACKUP_BASE_DIR"
    fi
}

# Limpar backups antigos
cleanup_old_backups() {
    local retention_days="${1:-$BACKUP_RETENTION_DAYS}"
    
    if [[ -d "$BACKUP_BASE_DIR" ]]; then
        info "Limpando backups com mais de $retention_days dias..."
        
        local deleted_count=0
        while IFS= read -r -d '' file; do
            rm -f "$file" "${file}.sha256"
            ((deleted_count++))
        done < <(find "$BACKUP_BASE_DIR" -name "*.bak" -type f -mtime +$retention_days -print0)
        
        if [[ $deleted_count -gt 0 ]]; then
            success "Removidos $deleted_count backups antigos"
        else
            info "Nenhum backup antigo para remover"
        fi
        
        # Remover diretórios vazios
        find "$BACKUP_BASE_DIR" -type d -empty -delete 2>/dev/null || true
    fi
}