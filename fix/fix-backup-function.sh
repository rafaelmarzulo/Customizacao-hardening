#!/bin/bash
# fix-backup-function.sh

echo "🔧 Corrigindo função backup_file..."

# Verificar se backup.sh existe
if [ -f "/opt/customizacao-hardening/scripts/utils/backup.sh" ]; then
    echo "✅ backup.sh encontrado"
    
    # Verificar se tem função backup_file
    if grep -q "backup_file" /opt/customizacao-hardening/scripts/utils/backup.sh; then
        echo "✅ Função backup_file existe"
    else
        echo "❌ Função backup_file não encontrada em backup.sh"
    fi
else
    echo "❌ backup.sh não encontrado"
    
    # Criar backup.sh
    echo "Criando backup.sh..."
    sudo tee /opt/customizacao-hardening/scripts/utils/backup.sh << 'EOF'
#!/bin/bash
# backup.sh - Funções de backup

backup_file() {
    local file="$1"
    local backup_dir="${2:-/var/backups/customizacao-hardening}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ ! -f "$file" ]; then
        echo "❌ Arquivo para backup não encontrado: $file"
        return 1
    fi
    
    mkdir -p "$backup_dir"
    local backup_file="${backup_dir}/$(basename "$file").backup.$timestamp"
    
    if cp "$file" "$backup_file"; then
        echo "✅ Backup criado: $backup_file"
        return 0
    else
        echo "❌ Falha ao criar backup de $file"
        return 1
    fi
}
EOF
    
    chmod +x /opt/customizacao-hardening/scripts/utils/backup.sh
    echo "✅ backup.sh criado"
fi

echo "🧪 Testando ssh-hardening..."
if sudo ssh-hardening --help >/dev/null 2>&1; then
    echo "✅ ssh-hardening funcionando!"
else
    echo "❌ ssh-hardening ainda com problemas"
fi
