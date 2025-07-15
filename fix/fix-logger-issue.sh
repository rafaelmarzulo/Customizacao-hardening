#!/bin/bash
# fix-logger-issue.sh

echo "🔧 Corrigindo problema do logger..."

# Backup do arquivo original
sudo cp /opt/customizacao-hardening/scripts/utils/logger.sh /opt/customizacao-hardening/scripts/utils/logger.sh.backup

# Aplicar correção
sudo sed -i '/^readonly SCRIPT_NAME=/c\[ -z "${SCRIPT_NAME:-}" ] && readonly SCRIPT_NAME=$(basename "$0")' /opt/customizacao-hardening/scripts/utils/logger.sh

echo "✅ Correção aplicada!"
echo "Testando scripts..."

# Testar scripts
echo "Testando server-setup..."
sudo server-setup --help 2>/dev/null && echo "✅ server-setup OK" || echo "❌ server-setup ainda com problema"

echo "Testando ssh-hardening..."
sudo ssh-hardening --help 2>/dev/null && echo "✅ ssh-hardening OK" || echo "❌ ssh-hardening ainda com problema"
