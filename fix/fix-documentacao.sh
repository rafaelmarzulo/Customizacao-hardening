#!/bin/bash
# fix-documentacao.sh - Corrige a documentação incompleta
# Versão: 1.0

set -euo pipefail

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
header() { echo -e "${PURPLE}🔧 $1${NC}"; }

header "CORRIGINDO DOCUMENTAÇÃO INCOMPLETA"

info "Criando INSTALACAO_AUTOMATIZADA.md completo..."

cat > INSTALACAO_AUTOMATIZADA.md << 'EOF'
# 🚀 Instalação Automatizada - Sistema de Hardening v2.0

## 📊 **VISÃO GERAL**

Este sistema oferece **instalação 100% automatizada** com detecção e correção automática de problemas, **incluindo configuração automática do SFTP** após hardening.

## ⚡ **INSTALAÇÃO EM 1 COMANDO**

### **Método 1: Auto-Install (Recomendado)**
```bash
# Clone o repositório
git clone https://github.com/rafaelmarzulo/Customizacao-hardening.git
cd Customizacao-hardening

# Instalação automatizada completa
sudo ./auto-install.sh
```

### **Método 2: Make Auto-Install**
```bash
# Instalação via Makefile
sudo make auto-install
```

### **Método 3: One-Click Install**
```bash
# Instalação em um clique
sudo make one-click-install
```

## 🔧 **O QUE A AUTOMAÇÃO FAZ**

### **✅ VERIFICAÇÃO AUTOMÁTICA:**
- ✅ Verifica dependências do sistema
- ✅ Detecta distribuição Linux
- ✅ Valida versões de software
- ✅ Instala dependências ausentes
- ✅ Verifica OpenSSH Server

### **✅ CORREÇÃO AUTOMÁTICA:**
- ✅ Corrige logger com conflitos readonly
- ✅ Implementa função backup_file
- ✅ Configura config.yaml enterprise
- ✅ Instala yq automaticamente
- ✅ Corrige caminhos de templates
- ✅ **CONFIGURA SFTP AUTOMATICAMENTE** 🆕

### **✅ INSTALAÇÃO INTELIGENTE:**
- ✅ Copia scripts para locais corretos
- ✅ Cria links simbólicos
- ✅ Configura permissões
- ✅ Valida funcionamento
- ✅ Testa todos os comandos

### **✅ VALIDAÇÃO COMPLETA:**
- ✅ Testa comandos principais
- ✅ Verifica arquivos de configuração
- ✅ Valida serviços do sistema
- ✅ Confirma funcionamento do SFTP
- ✅ Gera relatório de status

## 🎯 **COMANDOS DISPONÍVEIS APÓS INSTALAÇÃO**

### **Comandos Principais:**
```bash
sudo ssh-hardening      # Aplicar hardening SSH
sudo server-setup       # Configuração inicial do servidor
sudo clamav-setup       # Instalar e configurar ClamAV
sudo clamav-scan        # Executar scan de vírus
```

### **Comandos de Automação:**
```bash
make auto-install       # Instalação automatizada
make diagnose          # Diagnóstico completo
make validate          # Validar instalação
make fix-sftp          # Corrigir SFTP especificamente
make test-sftp         # Testar SFTP
make auto-fix          # Correção automática
```

### **Comandos de Status:**
```bash
make status            # Status geral do sistema
make help              # Ajuda completa
```

## 🧪 **TESTE DA INSTALAÇÃO**

### **Verificar se tudo foi instalado:**
```bash
# Verificar comandos
ssh-hardening --help
server-setup --help
clamav-setup --help

# Verificar status
make status
make validate
```

### **Aplicar hardening completo:**
```bash
# Sequência recomendada
sudo server-setup
sudo ssh-hardening
sudo clamav-setup

# Verificar resultado
make status
```

### **Testar SFTP após hardening:**
```bash
# Testar transferência de arquivos
sftp usuario@localhost
```

## 🔧 **SOLUÇÃO DE PROBLEMAS**

### **Se algo falhar:**
```bash
# Diagnóstico automático
make diagnose

# Correção automática
sudo make auto-fix

# Reinstalação completa
sudo make reinstall
```

### **Logs e debugging:**
```bash
# Ver logs do sistema
tail -f /var/log/auth.log

# Ver logs do hardening
ls -la /var/log/customizacao-hardening/

# Status dos serviços
systemctl status ssh
systemctl status clamav-daemon
```

## 📋 **ESTRUTURA CRIADA**

### **Arquivos de Sistema:**
```
/opt/customizacao-hardening/          # Instalação principal
/etc/customizacao-hardening/          # Configurações
/usr/local/bin/                       # Comandos globais
/var/log/customizacao-hardening/      # Logs
/var/backups/customizacao-hardening/  # Backups
```

### **Comandos Globais:**
```
/usr/local/bin/ssh-hardening
/usr/local/bin/server-setup
/usr/local/bin/clamav-setup
/usr/local/bin/clamav-scan
```

## 🏆 **BENEFÍCIOS DA AUTOMAÇÃO**

### **Para Usuários:**
- ✅ **Instalação em 1 comando** - sem complexidade
- ✅ **Correção automática** - sem intervenção manual
- ✅ **Validação completa** - garantia de funcionamento
- ✅ **SFTP funcional** - transferência de arquivos mantida

### **Para Administradores:**
- ✅ **Deployment rápido** - múltiplos servidores
- ✅ **Padronização** - configuração consistente
- ✅ **Auditoria** - logs completos de instalação
- ✅ **Manutenção** - atualizações simplificadas

### **Para Desenvolvedores:**
- ✅ **Testes automatizados** - CI/CD integrado
- ✅ **Ambiente reproduzível** - desenvolvimento consistente
- ✅ **Debugging facilitado** - logs estruturados
- ✅ **Contribuição simplificada** - setup rápido

## 🚀 **PRÓXIMOS PASSOS**

### **Após Instalação Bem-Sucedida:**
1. **Aplicar hardening:** `sudo ssh-hardening`
2. **Configurar servidor:** `sudo server-setup`
3. **Instalar antivírus:** `sudo clamav-setup`
4. **Testar SFTP:** `sftp usuario@localhost`
5. **Verificar status:** `make status`

### **Para Produção:**
1. **Testar em ambiente de desenvolvimento**
2. **Validar configurações específicas**
3. **Aplicar em servidores de produção**
4. **Monitorar logs e performance**
5. **Documentar configurações customizadas**

## 📞 **SUPORTE**

### **Documentação:**
- README.md - Documentação principal
- Makefile - Comandos disponíveis
- scripts/ - Código fonte dos scripts

### **Logs:**
- /var/log/customizacao-hardening/ - Logs do sistema
- /var/log/auth.log - Logs de autenticação
- systemctl status - Status dos serviços

### **Comunidade:**
- GitHub Issues - Reportar problemas
- GitHub Discussions - Discussões gerais
- Pull Requests - Contribuições

---

## 🎉 **PARABÉNS!**

Você agora tem um **sistema de hardening enterprise-grade** com:
- ✅ **Instalação 100% automatizada**
- ✅ **SFTP funcional após hardening**
- ✅ **Correção automática de problemas**
- ✅ **Validação completa do sistema**
- ✅ **Documentação abrangente**

**Seu servidor está pronto para ser protegido com segurança enterprise!** 🛡️🚀
EOF

success "INSTALACAO_AUTOMATIZADA.md criado com sucesso!"

info "Verificando se o arquivo foi criado corretamente..."
if [ -f "INSTALACAO_AUTOMATIZADA.md" ]; then
    success "Arquivo criado: $(wc -l < INSTALACAO_AUTOMATIZADA.md) linhas"
else
    error "Falha ao criar arquivo"
    exit 1
fi

header "🎉 DOCUMENTAÇÃO CORRIGIDA COM SUCESSO!"
echo ""
info "Agora você pode testar a instalação automatizada:"
echo "  sudo ./auto-install.sh"
echo ""
info "Ou usar os novos comandos do Makefile:"
echo "  make auto-install"
echo "  make diagnose"
echo "  make validate"

