#!/bin/bash
# fix-ssh-template-path.sh

echo "🔧 Corrigindo caminho do template SSH..."

# Verificar se template existe no local correto
if [ -f "/etc/customizacao-hardening/configs/ssh/sshd_config.template" ]; then
    echo "✅ Template encontrado em configs/ssh/"
    
    # Corrigir caminho no script ssh-hardening
    sudo sed -i 's|/etc/customizacao-hardening/sshd_config.template|/etc/customizacao-hardening/configs/ssh/sshd_config.template|g' /opt/customizacao-hardening/scripts/hardening/ssh_hardening.sh
    
    echo "✅ Caminho corrigido no script ssh-hardening"
    
    # Testar correção
    echo "🧪 Testando ssh-hardening..."
    if sudo ssh-hardening --help >/dev/null 2>&1; then
        echo "✅ ssh-hardening funcionando!"
    else
        echo "❌ ssh-hardening ainda com problemas"
    fi
    
else
    echo "❌ Template não encontrado!"
    exit 1
fi
