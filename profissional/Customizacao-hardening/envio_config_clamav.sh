#!/usr/bin/env bash
# configura_clamav.sh — Configura logrotate e agendamento diário do ClamAV
# Compatível com Ubuntu/Debian

set -euo pipefail
IFS=$'\n\t'

LOGROTATE_DEST="/etc/logrotate.d/clamav-all"
CLAMSCAN_SCRIPT_DEST="/usr/local/bin/clamscan_daily.sh"
CRON_JOB="0 2 * * * root $CLAMSCAN_SCRIPT_DEST"

# ─── Funções ──────────────────────────────────────────────────────────────

log() { echo -e "[INFO] $*"; }
error() { echo -e "[ERRO] $*" >&2; exit 1; }

# ─── Etapas ───────────────────────────────────────────────────────────────

log "▶️ Iniciando configuração do ClamAV..."

# 1. Copia configuração do logrotate
if [[ -f clamav-all ]]; then
    cp clamav-all "$LOGROTATE_DEST"
    log "✔️ Arquivo 'clamav-all' instalado em $LOGROTATE_DEST"
else
    error "Arquivo clamav-all não encontrado no diretório atual."
fi

# 2. Copia script clamscan
if [[ -f clamscan_daily.sh ]]; then
    cp clamscan_daily.sh "$CLAMSCAN_SCRIPT_DEST"
    chmod +x "$CLAMSCAN_SCRIPT_DEST"
    log "✔️ Script 'clamscan_daily.sh' instalado em $CLAMSCAN_SCRIPT_DEST"
else
    error "Arquivo clamscan_daily.sh não encontrado no diretório atual."
fi

# 3. Agendamento no cron (em /etc/crontab)
if ! grep -qF "$CLAMSCAN_SCRIPT_DEST" /etc/crontab; then
    echo "$CRON_JOB" >> /etc/crontab
    log "📆 Agendamento diário adicionado ao /etc/crontab para 02:00"
else
    log "ℹ️ O script já está agendado no /etc/crontab"
fi

log "✅ Configuração do ClamAV concluída."
