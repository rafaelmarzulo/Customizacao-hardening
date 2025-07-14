#!/bin/bash

# 🗄️ Script: backup.sh
# Descrição: Executa backup dos arquivos e diretórios definidos
# Versão: 1.0.0

if [[ "${1:-}" == "--help" ]]; then
  echo "🗄️  Script de Backup"
  echo "Uso: backup.sh [--help]"
  echo
  echo "Este script realiza backup dos arquivos de configuração e scripts do projeto."
  echo
  echo "Opções:"
  echo "  --help         Exibe esta mensagem de ajuda"
  exit 0
fi

tar -czf /var/backups/hardening/backup_$(date +%F_%T).tar.gz /etc/customizacao-hardening /opt/customizacao-hardening
