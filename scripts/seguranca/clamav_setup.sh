#!/bin/bash
# clamav_setup.sh - Instalação e configuração completa do ClamAV
# Customizacao-hardening project

set -euo pipefail

# Importar logger
source /opt/customizacao-hardening/scripts/utils/logger.sh 2>/dev/null || {
    # Funções básicas se logger não estiver disponível
    info() { echo "ℹ️  $1"; }
    success() { echo "✅ $1"; }
    warning() { echo "⚠️  $1"; }
    error() { echo "❌ $1"; }
}

# Verificar se está executando como root
if [ "$EUID" -ne 0 ]; then
    error "Execute como root: sudo $0"
    exit 1
fi

info "Iniciando instalação do ClamAV..."

# Atualizar repositórios
info "Atualizando repositórios..."
apt update

# Instalar ClamAV
info "Instalando ClamAV e componentes..."
apt install -y clamav clamav-daemon clamav-freshclam

# Parar serviços para configuração
info "Parando serviços para configuração..."
systemctl stop clamav-freshclam 2>/dev/null || true
systemctl stop clamav-daemon 2>/dev/null || true

# Aplicar configurações
info "Aplicando configurações personalizadas..."
if [ -f "/etc/customizacao-hardening/clamav/clamd.conf.template" ]; then
    cp /etc/customizacao-hardening/clamav/clamd.conf.template /etc/clamav/clamd.conf
    success "Configuração clamd.conf aplicada"
fi

if [ -f "/etc/customizacao-hardening/clamav/freshclam.conf.template" ]; then
    cp /etc/customizacao-hardening/clamav/freshclam.conf.template /etc/clamav/freshclam.conf
    success "Configuração freshclam.conf aplicada"
fi

# Ajustar permissões
chown clamav:clamav /etc/clamav/clamd.conf /etc/clamav/freshclam.conf 2>/dev/null || true
chmod 644 /etc/clamav/clamd.conf /etc/clamav/freshclam.conf

# Atualizar base de dados
info "Atualizando base de dados de vírus..."
freshclam

# Habilitar e iniciar serviços
info "Habilitando e iniciando serviços..."
systemctl enable clamav-freshclam
systemctl enable clamav-daemon
systemctl start clamav-freshclam
systemctl start clamav-daemon

# Verificar status
info "Verificando status dos serviços..."
if systemctl is-active --quiet clamav-daemon && systemctl is-active --quiet clamav-freshclam; then
    success "ClamAV instalado e configurado com sucesso!"
    info "Serviços ativos:"
    info "  - clamav-daemon: $(systemctl is-active clamav-daemon)"
    info "  - clamav-freshclam: $(systemctl is-active clamav-freshclam)"
else
    warning "ClamAV instalado, mas alguns serviços podem não estar ativos"
    info "Status dos serviços:"
    info "  - clamav-daemon: $(systemctl is-active clamav-daemon)"
    info "  - clamav-freshclam: $(systemctl is-active clamav-freshclam)"
fi

success "Instalação do ClamAV concluída!"
