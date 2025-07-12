#!/bin/bash

# 🛡️ Script: clamscan_daily.sh
# Descrição: Varredura diária com o ClamAV
# Versão: 1.0.0

if [[ "${1:-}" == "--help" ]]; then
  echo "🛡️  Script de Varredura Diária com ClamAV"
  echo "Uso: clamscan_daily.sh [--help]"
  echo
  echo "Este script executa uma varredura diária com o ClamAV em diretórios padrão."
  echo
  echo "Opções:"
  echo "  --help         Exibe esta mensagem de ajuda"
  exit 0
fi

clamscan -r /home /var /etc --quiet --log=/var/log/hardening/clamscan_daily.log
