#!/bin/bash

# 📤 Script: envio_config_clamav.sh
# Descrição: Envia as configurações do ClamAV para o diretório correto
# Versão: 1.0.0

if [[ "${1:-}" == "--help" ]]; then
  echo "📤  Script de Envio de Configuração do ClamAV"
  echo "Uso: envio_config_clamav.sh [--help]"
  echo
  echo "Este script copia os arquivos de configuração do ClamAV para o sistema."
  echo
  echo "Opções:"
  echo "  --help         Exibe esta mensagem de ajuda"
  exit 0
fi

cp clamd.conf /etc/clamav/
cp freshclam.conf /etc/clamav/
systemctl restart clamav-daemon
