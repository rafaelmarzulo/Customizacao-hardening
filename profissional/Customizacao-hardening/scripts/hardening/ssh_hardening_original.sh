#!/bin/bash

# Nome do script: hardening_ssh_local.sh
# Finalidade: Aplicar boas práticas de segurança no SSH sem criar usuários ou gerar chaves
# Autor: Rafael 

set -e

echo "🔐 Iniciando hardening do SSH..."

# Verificar se o diretório ~/.ssh existe
if [[ ! -d ~/.ssh ]]; then
    echo "⚠️ Diretório ~/.ssh não encontrado. Crie com: mkdir -p ~/.ssh"
fi

# Verificar se existe chave privada ou authorized_keys
if [[ -f ~/.ssh/id_rsa || -f ~/.ssh/id_ed25519 || -f ~/.ssh/id_ecdsa ]]; then
    echo "✅ Chave privada encontrada em ~/.ssh"
elif [[ -f ~/.ssh/authorized_keys ]]; then
    echo "✅ authorized_keys encontrado: esta máquina aceita conexões por chave pública."
else
    echo "⚠️ Nenhuma chave privada ou authorized_keys encontrada em ~/.ssh"
    echo "Você pode criar uma com: ssh-keygen -t ed25519"
fi

# Backup do arquivo de configuração
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bkp_$(date +%F_%H-%M-%S)"

echo "📝 Criando backup do arquivo de configuração SSH..."
sudo cp "$SSHD_CONFIG" "$BACKUP_FILE"
echo "📁 Backup salvo em: $BACKUP_FILE"

# Aplicar hardening no SSHD config
echo "🔧 Aplicando configurações de segurança..."

sudo sed -i \
  -e 's/^#\?\s*PermitRootLogin.*/PermitRootLogin no/' \
  -e 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
  -e 's/^#\?\s*UsePAM.*/UsePAM no/' \
  -e 's/^#\?\s*X11Forwarding.*/X11Forwarding no/' \
  -e 's/^#\?\s*PermitEmptyPasswords.*/PermitEmptyPasswords no/' \
  -e 's/^#\?\s*ClientAliveInterval.*/ClientAliveInterval 300/' \
  -e 's/^#\?\s*ClientAliveCountMax.*/ClientAliveCountMax 2/' \
  "$SSHD_CONFIG"

# Garante que apenas autenticação por chave seja permitida
if ! grep -q "^PubkeyAuthentication yes" "$SSHD_CONFIG"; then
    echo "✅ Ativando PubkeyAuthentication..."
    echo "PubkeyAuthentication yes" | sudo tee -a "$SSHD_CONFIG" > /dev/null
fi

echo "✅ Configurações de hardening aplicadas com sucesso."

# Reiniciar serviço SSH
read -p "🔁 Deseja reiniciar o serviço SSH agora? (s/n): " resp
if [[ "$resp" =~ ^[sS]$ ]]; then
    sudo systemctl restart ssh
    echo "✅ Serviço SSH reiniciado."
else
    echo "⚠️ Lembre-se de reiniciar manualmente com: sudo systemctl restart ssh"
fi
