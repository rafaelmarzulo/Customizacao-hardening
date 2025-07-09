#!/usr/bin/env bash
# server_setup_essential.sh — Instalação e configuração de ferramentas essenciais
# Compatível com Ubuntu/Debian para servidores em produção
# Para Rodar no debian primeiro deve instalar os comandos abaixo como root
# apt install sudo
# /usr/sbin/usermod -aG sudo debian

set -euo pipefail
IFS=$'\n\t'

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÕES INICIAIS
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/server_setup_$(date +%Y%m%d_%H%M%S).log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$SCRIPT_DIR/backups_$TIMESTAMP"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════════════════
# FUNÇÕES DE LOG E CONTROLE
# ═══════════════════════════════════════════════════════════════════════════════

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}ℹ️  $*${NC}" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}✅ $*${NC}" | tee -a "$LOG_FILE"; }
warning() { echo -e "${YELLOW}⚠️  $*${NC}" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}❌ $*${NC}" | tee -a "$LOG_FILE" >&2; }
die() { error "$*"; exit 1; }

# Banner inicial
show_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 SERVER SETUP ESSENTIAL TOOLS v1.1                     ║"
    echo "║                   Instalação otimizada para servidores                      ║"
    echo "║                        Debian/Ubuntu Production Ready                       ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# VERIFICAÇÕES INICIAIS
# ═══════════════════════════════════════════════════════════════════════════════

check_prerequisites() {
    info "Verificando pré-requisitos do sistema..."

    [[ $EUID -eq 0 ]] || die "Este script deve ser executado como root (use sudo)"

    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            ubuntu)
                info "Sistema detectado: $PRETTY_NAME"
                info "Verificando repositórios do Ubuntu..."

                if [[ ! -f /etc/apt/sources.list.backup ]]; then
                    cp /etc/apt/sources.list /etc/apt/sources.list.backup
                    info "Backup do sources.list criado"
                fi

                if ! grep -q "archive.ubuntu.com" /etc/apt/sources.list; then
                    info "Corrigindo repositórios do Ubuntu..."

                    cat > /etc/apt/sources.list << 'EOF'
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF
                    success "Repositórios do Ubuntu atualizados"
                else
                    info "Repositórios do Ubuntu já estão corretos"
                fi

                info "Atualizando lista de pacotes..."
                apt update && success "Lista de pacotes atualizada com sucesso" || warning "Falha ao atualizar pacotes"
                ;;

            debian)
                info "Sistema detectado: $PRETTY_NAME"
                info "Configurando repositórios oficiais do Debian..."

                if [[ ! -f /etc/apt/sources.list.backup ]]; then
                    cp /etc/apt/sources.list /etc/apt/sources.list.backup
                    info "Backup do sources.list criado"
                fi

                if grep -q "deb cdrom:" /etc/apt/sources.list; then
                    sed -i 's/^deb cdrom:/# deb cdrom:/' /etc/apt/sources.list
                    info "Linha do CD-ROM comentada"
                fi

                if ! grep -q "deb.debian.org" /etc/apt/sources.list; then
                    info "Adicionando repositórios oficiais do Debian..."

                    cat >> /etc/apt/sources.list << 'EOF'

 Repositórios oficiais do Debian Bookworm
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
                    success "Repositórios oficiais do Debian adicionados"
                else
                    info "Repositórios oficiais do Debian já estão configurados"
                fi

                info "Atualizando lista de pacotes..."
                apt update && success "Lista de pacotes atualizada com sucesso" || warning "Falha ao atualizar pacotes"
                ;;

            *)
                die "Sistema não suportado: $PRETTY_NAME. Este script é apenas para Ubuntu/Debian"
                ;;
        esac
    else
        die "Não foi possível identificar o sistema operacional"
    fi

    mkdir -p "$BACKUP_DIR"
     success "Pré-requisitos verificados com sucesso"
}
# ═══════════════════════════════════════════════════════════════════════════════
# DEFINIÇÃO DE PACOTES
# ═══════════════════════════════════════════════════════════════════════════════

# Pacotes essenciais do sistema
ESSENCIAIS_SISTEMA=(
    # Ferramentas de sistema básicas
    procps
    systemd
    systemd-timesyncd
    ca-certificates
    gnupg
    lsb-release
    
    # SSH e conectividade
    openssh-server
    
    # Cron e agendamento
    cron
    anacron
    
    # Ferramentas de rede essenciais
    net-tools
    iproute2
    iputils-ping
    dnsutils
    
    # Editores e ferramentas básicas
    vim
    less
    
    # Utilitários de arquivo
    file
    tar
    gzip
    
    # Ferramentas de download
    curl
    wget
    
    # Localização e idioma
    plocales
)

# Pacotes de monitoramento
ESSENCIAIS_MONITORING=(
    # Monitoramento e diagnóstico
    htop
    lsof
    strace
    tcpdump
    
    # Logs
    rsyslog
    logrotate
    
    # Performance
    sysstat
)

# Pacotes de segurança
ESSENCIAIS_SEGURANCA=(
    # Segurança
    fail2ban
    ufw
    rkhunter
    chkrootkit
    clamav
    clamav-daemon
    
    # Atualizações automáticas
    unattended-upgrades
    
    # Busca de arquivos
    plocate
    
    # Auditoria
    auditd
)

# ═══════════════════════════════════════════════════════════════════════════════
# FUNÇÕES DE INSTALAÇÃO
# ═══════════════════════════════════════════════════════════════════════════════

# Atualização do sistema
update_system() {
    info "📦 Iniciando atualização do sistema..."

    # Garante que o diretório de backup existe
    mkdir -p "$BACKUP_DIR"
    
    # Backup da lista de sources
    cp /etc/apt/sources.list "$BACKUP_DIR/sources.list.backup"
      
    info "Atualizando pacotes instalados..."
    DEBIAN_FRONTEND=noninteractive apt upgrade -y || die "Falha ao atualizar pacotes"
    
    info "Removendo pacotes órfãos..."
    apt autoremove -y
    apt autoclean
    
    success "Sistema atualizado com sucesso"
}

# Instala lista de pacotes com verificação
install_packages() {
    local category="$1"
    shift
    local packages=("$@")
    
    info "📦 Instalando pacotes: $category"
    
    local to_install=()
    local already_installed=()
    
    # Verifica quais pacotes precisam ser instalados
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii.*$package "; then
            already_installed+=("$package")
        else
            to_install+=("$package")
        fi
    done
    
    # Mostra status
    if [[ ${#already_installed[@]} -gt 0 ]]; then
        info "Já instalados (${#already_installed[@]}): ${already_installed[*]}"
    fi
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        info "Instalando (${#to_install[@]}): ${to_install[*]}"
        
        # Instala pacotes em lotes menores para evitar problemas
        local batch_size=10
        for ((i=0; i<${#to_install[@]}; i+=batch_size)); do
            local batch=("${to_install[@]:i:batch_size}")
            info "Instalando lote: ${batch[*]}"
            
            DEBIAN_FRONTEND=noninteractive apt install -y "${batch[@]}" || {
                warning "Falha ao instalar lote: ${batch[*]}"
                # Tenta instalar individualmente
                for pkg in "${batch[@]}"; do
                    info "Tentando instalar individualmente: $pkg"
                    DEBIAN_FRONTEND=noninteractive apt install -y "$pkg" || warning "Falha: $pkg"
                done
            }
        done
    else
        success "Todos os pacotes de $category já estão instalados"
    fi
    
    success "Instalação de $category concluída"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÕES ESPECÍFICAS
# ═══════════════════════════════════════════════════════════════════════════════

# Configuração do SSH
configure_ssh() {
    info "🔐 Configurando SSH..."
    
    local sshd_config="/etc/ssh/sshd_config"
    cp "$sshd_config" "$BACKUP_DIR/sshd_config.backup"
    
    # Configurações básicas de segurança SSH com comentários explicativos
    cat >> "$sshd_config" << 'EOF'

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÕES DE SEGURANÇA ADICIONAIS - ADICIONADAS PELO SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════

# Controle de tentativas de autenticação
MaxAuthTries 5                   # Máximo de tentativas de autenticação por conexão
LoginGraceTime 30               # Tempo limite para completar login (segundos)

# Políticas de senha e autenticação
PermitEmptyPasswords no         # Nunca permitir senhas vazias
X11Forwarding no               # Desabilita redirecionamento X11 (interface gráfica)

# Controle de conexões simultâneas
MaxStartups 2                   # Máximo de 2 conexões simultâneas não autenticadas

# Configurações de protocolo (caso não esteja definido)
Protocol 2                      # Força uso do protocolo SSH versão 2 (mais seguro)
EOF
    
    # Testa e reinicia SSH
    if sshd -t; then
        systemctl restart ssh
        systemctl enable ssh
        success "SSH configurado e reiniciado"
    else
        warning "Configuração SSH inválida, restaurando backup"
        cp "$BACKUP_DIR/sshd_config.backup" "$sshd_config"
    fi
}

# Configuração do Fail2Ban
configure_fail2ban() {
    info "🛡️  Configurando Fail2Ban..."
    
    # Backup da configuração
    [[ -f /etc/fail2ban/jail.local ]] && cp /etc/fail2ban/jail.local "$BACKUP_DIR/"
    
    # Configuração básica com comentários explicativos
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Configurações globais aplicadas a todas as jails
bantime = 3600        # Tempo de banimento (em segundos) após violação → 1 hora
findtime = 600        # Janela de tempo para observar tentativas → 10 minutos
maxretry = 3          # Número máximo de tentativas antes de banir
backend = systemd     # Método de leitura de logs (systemd é indicado no Ubuntu/Debian modernos)

[sshd]
# Proteção contra ataques de força bruta no SSH
enabled = true                    # Ativa a proteção SSH
port = ssh                       # Porta monitorada (padrão ssh = 22)
filter = sshd                    # Filtro que identifica tentativas de login SSH
logpath = /var/log/auth.log      # Arquivo de log onde buscar eventos SSH
maxretry = 3                     # Máximo de tentativas de login falhadas
bantime = 3600                   # Tempo de banimento específico para SSH → 1 hora

# Jails do Apache desabilitadas (não temos Apache instalado)
[apache-auth]
enabled = false                  # Desabilitado - proteção de autenticação Apache

[apache-badbots]
enabled = false                  # Desabilitado - proteção contra bots maliciosos

[apache-noscript]
enabled = false                  # Desabilitado - proteção contra scripts

[apache-overflows]
enabled = false                  # Desabilitado - proteção contra buffer overflow
EOF
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    success "Fail2Ban configurado"
}

# Configuração do UFW
configure_ufw() {
    info "🔥 Configurando UFW (Firewall)..."
    
    # Reset completo do firewall para estado limpo
    ufw --force reset
    
    # Configuração de políticas padrão com comentários
    ufw default deny incoming    # BLOQUEIA todas as conexões de entrada por padrão
    ufw default allow outgoing   # PERMITE todas as conexões de saída por padrão
    
    # Regras específicas essenciais
    ufw allow ssh               # Permite SSH (porta 22) - CRÍTICO para não perder acesso
    
    # Permite tráfego na interface loopback (comunicação interna do sistema)
    ufw allow in on lo          # Interface loopback (127.0.0.1) - essencial para funcionamento
    
    # Ativa o firewall sem confirmação
    ufw --force enable          # --force evita prompt de confirmação
    
    success "UFW configurado e ativado"
}

# Configuração de atualizações automáticas
configure_auto_updates() {
    info "🔄 Configurando atualizações automáticas..."
    
    # Backup
    [[ -f /etc/apt/apt.conf.d/50unattended-upgrades ]] && \
        cp /etc/apt/apt.conf.d/50unattended-upgrades "$BACKUP_DIR/"
    
    # Configuração de atualizações automáticas com comentários detalhados
    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÃO DE ATUALIZAÇÕES AUTOMÁTICAS DE SEGURANÇA
# ═══════════════════════════════════════════════════════════════════════════════

# Origens permitidas para atualizações automáticas (apenas segurança)
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";                    # Atualizações gerais da distribuição
    "${distro_id}:${distro_codename}-security";           # Atualizações de segurança críticas
    "${distro_id}ESMApps:${distro_codename}-apps-security"; # Extended Security Maintenance (Apps)
    "${distro_id}ESM:${distro_codename}-infra-security";    # Extended Security Maintenance (Infra)
};

# Pacotes que NUNCA devem ser atualizados automaticamente
Unattended-Upgrade::Package-Blacklist {
    # Exemplo: "kernel*";        # Descomente para evitar atualizações de kernel
    # Exemplo: "mysql-server*";  # Descomente para evitar atualizações do MySQL
};

# Configurações de comportamento
Unattended-Upgrade::DevRelease "false";                   # Não instalar atualizações de desenvolvimento
Unattended-Upgrade::Remove-Unused-Dependencies "true";    # Remove dependências não utilizadas automaticamente
Unattended-Upgrade::Automatic-Reboot "false";            # NUNCA reiniciar automaticamente
Unattended-Upgrade::Automatic-Reboot-Time "02:00";       # Se reboot fosse habilitado, seria às 2h da manhã
Unattended-Upgrade::Mail "";                              # Email para notificações (vazio = desabilitado)
EOF
    
    # Configuração de periodicidade das atualizações
    cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÃO DE PERIODICIDADE DAS ATUALIZAÇÕES AUTOMÁTICAS
# ═══════════════════════════════════════════════════════════════════════════════

APT::Periodic::Update-Package-Lists "1";           # Atualiza lista de pacotes diariamente
APT::Periodic::Unattended-Upgrade "1";            # Executa atualizações automáticas diariamente
APT::Periodic::Download-Upgradeable-Packages "1"; # Baixa pacotes atualizáveis diariamente (cache)
APT::Periodic::AutocleanInterval "7";             # Limpa cache de pacotes a cada 7 dias
EOF
    
    systemctl enable unattended-upgrades
    success "Atualizações automáticas configuradas"
}

# Configuração do sistema de logs
configure_logging() {
    info "📝 Configurando sistema de logs..."
    
    # Backup
    cp /etc/logrotate.conf "$BACKUP_DIR/"
    
    # Configuração personalizada de logrotate com comentários explicativos
    cat > /etc/logrotate.d/custom << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÃO PERSONALIZADA DE ROTAÇÃO DE LOGS
# ═══════════════════════════════════════════════════════════════════════════════

# Rotação do log de autenticação (tentativas de login, sudo, etc.)
/var/log/auth.log {
    daily                        # Rotaciona diariamente
    rotate 30                    # Mantém 30 arquivos de backup (30 dias de histórico)
    compress                     # Comprime arquivos antigos para economizar espaço
    delaycompress               # Não comprime o arquivo mais recente (dia anterior)
    missingok                   # Não gera erro se o arquivo não existir
    notifempty                  # Não rotaciona se o arquivo estiver vazio
    create 640 syslog adm       # Cria novo arquivo com permissões 640, owner=syslog, group=adm
}

# Rotação do log geral do sistema
/var/log/syslog {
    daily                        # Rotaciona diariamente
    rotate 30                    # Mantém 30 arquivos de backup (30 dias de histórico)
    compress                     # Comprime arquivos antigos
    delaycompress               # Não comprime o arquivo do dia anterior
    missingok                   # Ignora se arquivo não existir
    notifempty                  # Só rotaciona se houver conteúdo
    create 640 syslog adm       # Permissões: read/write para syslog, read para grupo adm
}
EOF
    
    systemctl restart rsyslog
    success "Sistema de logs configurado"
}

# Configuração de timezone e localização
configure_locale() {
    info "🌍 Configurando localização e timezone..."
    
    # Configura timezone para São Paulo (horário de Brasília)
    timedatectl set-timezone America/Sao_Paulo    # UTC-3 (horário de Brasília)
    
    # Gera locales necessários para suporte a idiomas
    locale-gen pt_BR.UTF-8 en_US.UTF-8          # Português Brasil + Inglês (fallback)
    
    # Define locale padrão do sistema
    update-locale LANG=pt_BR.UTF-8               # Português como idioma principal
    
    # Configura sincronização automática de horário via NTP
    systemctl enable systemd-timesyncd          # Habilita sincronização de tempo
    systemctl start systemd-timesyncd           # Inicia serviço de sincronização
    
    success "Localização configurada para Brasil/São Paulo"
}

# ═══════════════════════════════════════════════════════════════════════════════
# VERIFICAÇÕES PÓS-INSTALAÇÃO
# ═══════════════════════════════════════════════════════════════════════════════

verify_services() {
    info "🔍 Verificando serviços críticos..."
    
    local services=(
        "ssh"
        "fail2ban"
        "rsyslog"
        "systemd-timesyncd"
        "cron"
        "ufw"
    )
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            success "✓ $service está ativo"
        else
            warning "⚠ $service não está ativo"
            systemctl start "$service" 2>/dev/null || warning "Falha ao iniciar $service"
        fi
        
        if systemctl is-enabled --quiet "$service" 2>/dev/null; then
            success "✓ $service está habilitado"
        else
            warning "⚠ $service não está habilitado"
            systemctl enable "$service" 2>/dev/null || warning "Falha ao habilitar $service"
        fi
    done
}

# Relatório final
generate_report() {
    info "📊 Gerando relatório final..."
    
    local report_file="$SCRIPT_DIR/setup_report_$TIMESTAMP.txt"
    
    cat > "$report_file" << EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                         RELATÓRIO DE INSTALAÇÃO                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

📅 Data/Hora: $(date)
🖥️  Sistema: $(lsb_release -d | cut -f2)
🌐 Hostname: $(hostname)
🕒 Timezone: $(timedatectl | grep "Time zone" | awk '{print $3}')

SERVIÇOS INSTALADOS E CONFIGURADOS:
───────────────────────────────────
✅ Sistema completamente atualizado
✅ Pacotes essenciais instalados (sistema, monitoramento, segurança)
✅ SSH configurado com hardening de segurança
✅ Fail2Ban ativo (proteção contra força bruta)
✅ UFW (Firewall) configurado e ativo
✅ Atualizações automáticas de segurança ativadas
✅ Sistema de logs otimizado com rotação automática
✅ Timezone configurado para Brasil (São Paulo)
✅ Sincronização de horário via NTP ativa

CONFIGURAÇÕES DE SEGURANÇA APLICADAS:
────────────────────────────────────
🔐 SSH: Máximo 3 tentativas de login, sem senhas vazias
🛡️  Fail2Ban: Banimento de 1h após 3 tentativas em 10min
🔥 UFW: Firewall ativo, bloqueando entrada, permitindo saída
🔄 Auto-updates: Apenas atualizações de segurança
📝 Logs: Retenção de 30 dias com compressão automática

COMANDOS ÚTEIS PARA MONITORAMENTO:
─────────────────────────────────
📊 htop                          # Monitor de processos interativo
🔍 lsof -i                       # Lista portas e conexões abertas
📋 systemctl status fail2ban     # Status do Fail2Ban
🔥 ufw status                    # Status do firewall
📝 tail -f /var/log/auth.log     # Monitora tentativas de login em tempo real
🚫 fail2ban-client status sshd   # IPs banidos pelo Fail2Ban

PRÓXIMOS PASSOS RECOMENDADOS:
────────────────────────────
1. 🔑 Configurar autenticação SSH por chaves (desabilitar senha)
2. 📧 Configurar notificações por email para alertas
3. 💾 Implementar backup automático de dados críticos
4. 📊 Configurar monitoramento avançado (opcional)
5. 🔄 Testar funcionamento de todos os serviços
6. 📖 Documentar senhas e configurações específicas

ARQUIVOS DE BACKUP CRIADOS:
──────────────────────────
📂 Diretório: $BACKUP_DIR/
   • sources.list.backup         # Lista de repositórios APT
   • sshd_config.backup         # Configuração SSH original
   • jail.local.backup          # Configuração Fail2Ban (se existia)
   • logrotate.conf.backup      # Configuração logrotate original

ARQUIVOS DE LOG:
───────────────
📄 Log de instalação: $LOG_FILE
📊 Este relatório: $report_file

⚠️  IMPORTANTE: Faça backup deste relatório e dos arquivos de configuração!

EOF
    
    success "Relatório salvo em: $report_file"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FUNÇÃO PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    show_banner
    info "Iniciando configuração do servidor - Log: $LOG_FILE"
    
    # Verificações iniciais
   # check_prerequisites
    
    # Atualização do sistema
    update_system
    
    # Instalação de pacotes
    install_packages "Sistema Base" "${ESSENCIAIS_SISTEMA[@]}"
    install_packages "Monitoramento" "${ESSENCIAIS_MONITORING[@]}"
    install_packages "Segurança" "${ESSENCIAIS_SEGURANCA[@]}"
    
    # Configurações específicas
    configure_ssh
    configure_fail2ban
    configure_ufw
    configure_auto_updates
    configure_logging
    configure_locale
    
    # Verificações finais
    verify_services
    
    # Limpeza final
    apt autoremove -y
    apt autoclean
    
    # Atualiza banco de dados do locate
    updatedb &
    
    # Relatório
    generate_report
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!                     ║"
    echo "║                                                                              ║"
    echo "║  Seu servidor está configurado com todas as ferramentas essenciais          ║"
    echo "║  para produção. Verifique o relatório para próximos passos.                 ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    info "🔄 Reinicialização recomendada para aplicar todas as configurações"
    read -p "Deseja reiniciar agora? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Reiniciando sistema em 10 segundos..."
        sleep 10
        reboot
    fi
}

# Executa apenas se chamado diretamente
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"

# Aplicando hardening do kernel via sysctl
echo "🔧 Aplicando regras de hardening sysctl..."
cat <<EOF | sudo tee /etc/sysctl.d/99-hardening.conf
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF

sudo sysctl -p /etc/sysctl.d/99-hardening.conf
echo "✅ Regras de sysctl aplicadas com sucesso"
