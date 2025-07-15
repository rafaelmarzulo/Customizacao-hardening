#!/bin/bash
# sync-github.sh - Sincroniza GitHub com estrutura local

set -euo pipefail

echo "🔄 Sincronizando GitHub com estrutura local..."

# Verificar se estamos no diretório correto
if [[ ! -f "README.md" ]] || [[ ! -f "Makefile" ]]; then
    echo "❌ Execute este script no diretório raiz do projeto Customizacao-hardening"
    exit 1
fi

# Verificar status
echo "📋 Status atual:"
git status --short

# Adicionar todos os arquivos
echo "📁 Adicionando arquivos locais..."
git add .

# Verificar se há mudanças
if git diff --cached --quiet; then
    echo "✅ Nenhuma mudança detectada. Estrutura já sincronizada!"
    exit 0
fi

# Fazer commit
echo "💾 Fazendo commit da estrutura correta..."
git commit -m "fix(repo): sincroniza estrutura local com GitHub

- Corrige duplicação de diretórios no GitHub
- Mantém arquivos na raiz conforme estrutura local
- Remove inconsistências entre local e remoto
- Estrutura agora está padronizada"

# Push com force-with-lease (mais seguro que --force)
echo "🚀 Sincronizando com GitHub..."
if git push origin main --force-with-lease; then
    echo "✅ Sincronização concluída com sucesso!"
    echo "🔗 Verifique: https://github.com/rafaelmarzulo/Customizacao-hardening"
else
    echo "❌ Erro na sincronização. Tentando push normal..."
    git push origin main
fi

echo "🎉 GitHub sincronizado com estrutura local!"