#!/bin/bash
# scripts/hardening/ssh_hardening.sh
# Descrição: Script para hardening SSH
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025

set -euo pipefail

# Configurações
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly CONFIG_DIR="$PROJECT_ROOT/configs/ssh"
readonly UTILS_DIR="$PROJECT_ROOT/scripts/utils"

# Importar bibliotecas
source "$UTILS_DIR/logger.sh"
source "$UTILS_DIR/validator.sh"
source "$UTILS_DIR/backup.sh"

# Configurações SSH
readonly SSHD_CONFIG="/etc/ssh/sshd_config"
readonly SSH_CONFIG_TEMPLATE="$CONFIG_DIR/sshd_config.template"

# Configurações de hardening
declare -A SSH_HARDENING_CONFIG=(
    ["Port"]="22"
    ["Protocol"]="2"
    ["PermitRootLogin"]="no"
    ["PasswordAuthentication"]="no"
    ["PubkeyAuthentication"]="yes"
    ["AuthorizedKeysFile"]=".ssh/authorized_keys"
    ["PermitEmptyPasswords"]="no"
    ["ChallengeResponseAuthentication"]="no"
    ["UsePAM"]="yes"
    ["X11Forwarding"]="no"
    ["PrintMotd"]="no"
    ["ClientAliveInterval"]="300"
    ["ClientAliveCountMax"]="2"
    ["MaxAuthTries"]="3"
    ["MaxSessions"]="2"
    ["LoginGraceTime"]="60"
    ["AllowUsers"]=""
    ["DenyUsers"]=""
    ["AllowGroups"]="ssh-users"
    ["DenyGroups"]=""
)

# Função para mostrar ajuda
show_help() {
    cat << EOF
Uso: $0 [OPÇÕES]

Opções:
    -h, --help              Mostrar esta ajuda
    -c, --config FILE       Usar arquivo de configuração personalizado
    -p, --port PORT         Definir porta SSH (padrão: 22)
    -u, --allow-users USERS Lista de usuários permitidos (separados por vírgula)
    -g, --allow-groups GROUPS Lista de grupos permitidos (separados por vírgula)
    --dry-run               Mostrar mudanças sem aplicar
    --backup-only           Apenas fazer backup da configuração atual
    --restore BACKUP        Restaurar backup específico
    -v, --verbose           Modo verboso (DEBUG)
    -q, --quiet             Modo silencioso (apenas ERRORS)

Exemplos:
    $0                                    # Aplicar hardening padrão
    $0 -p 2222 -u "admin,user1"         # Porta 2222, usuários específicos
    $0 --dry-run                         # Visualizar mudanças
    $0 --restore /path/to/backup.bak     # Restaurar backup

EOF
}

# Processar argumentos da linha de comando
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                SSH_CONFIG_TEMPLATE="$2"
                shift 2
                ;;
            -p|--port)
                validate_port "$2"
                SSH_HARDENING_CONFIG["Port"]="$2"
                shift 2
                ;;
            -u|--allow-users)
                SSH_HARDENING_CONFIG["AllowUsers"]="$2"
                shift 2
                ;;
            -g|--allow-groups)
                SSH_HARDENING_CONFIG["AllowGroups"]="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --backup-only)
                BACKUP_ONLY=true
                shift
                ;;
            --restore)
                RESTORE_BACKUP="$2"
                shift 2
                ;;
            -v|--verbose)
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -q|--quiet)
                LOG_LEVEL="ERROR"
                shift
                ;;
            *)
                error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Validar configuração SSH
validate_ssh_config() {
    info "Validando configuração SSH..."
    
    # Testar configuração
    if ! sshd -t -f "$SSHD_CONFIG" 2>/dev/null; then
        error "Configuração SSH atual é inválida"
        return 1
    fi
    
    success "Configuração SSH válida"
}

# Verificar chaves SSH dos usuários
check_user_ssh_keys() {
    local users="${SSH_HARDENING_CONFIG[AllowUsers]}"
    
    [[ -z "$users" ]] && return 0
    
    info "Verificando chaves SSH dos usuários permitidos..."
    
    IFS=',' read -ra user_list <<< "$users"
    for user in "${user_list[@]}"; do
        user=$(echo "$user" | xargs) # trim whitespace
        
        if ! id "$user" &>/dev/null; then
            warn "Usuário não existe: $user"
            continue
        fi
        
        local user_home=$(getent passwd "$user" | cut -d: -f6)
        local ssh_dir="$user_home/.ssh"
        local auth_keys="$ssh_dir/authorized_keys"
        
        if [[ ! -f "$auth_keys" ]]; then
            warn "Usuário $user não possui chaves SSH configuradas: $auth_keys"
            info "Configure com: ssh-copy-id $user@localhost"
        else
            success "Usuário $user possui chaves SSH configuradas"
        fi
    done
}

# Aplicar configuração SSH
apply_ssh_config() {
    local temp_config="/tmp/sshd_config.new"
    
    info "Aplicando configuração de hardening SSH..."
    
    # Criar nova configuração
    {
        echo "# SSH Hardening Configuration"
        echo "# Generated by: $0"
        echo "# Date: $(date)"
        echo ""
        
        for key in "${!SSH_HARDENING_CONFIG[@]}"; do
            local value="${SSH_HARDENING_CONFIG[$key]}"
            [[ -n "$value" ]] && echo "$key $value"
        done
    } > "$temp_config"
    
    # Validar nova configuração
    if ! sshd -t -f "$temp_config"; then
        fatal "Nova configuração SSH é inválida"
    fi
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        info "=== DRY RUN - Mudanças que seriam aplicadas ==="
        diff -u "$SSHD_CONFIG" "$temp_config" || true
        rm -f "$temp_config"
        return 0
    fi
    
    # Fazer backup
    local backup_file
    backup_file=$(backup_file "$SSHD_CONFIG")
    
    # Aplicar nova configuração
    cp "$temp_config" "$SSHD_CONFIG"
    rm -f "$temp_config"
    
    success "Configuração SSH aplicada (backup: $backup_file)"
}

# Configurar grupo SSH
setup_ssh_group() {
    local group_name="${SSH_HARDENING_CONFIG[AllowGroups]}"
    
    [[ -z "$group_name" ]] && return 0
    
    info "Configurando grupo SSH: $group_name"
    
    # Criar grupo se não existir
    if ! getent group "$group_name" &>/dev/null; then
        groupadd "$group_name"
        success "Grupo criado: $group_name"
    else
        debug "Grupo já existe: $group_name"
    fi
    
    # Adicionar usuários ao grupo
    local users="${SSH_HARDENING_CONFIG[AllowUsers]}"
    if [[ -n "$users" ]]; then
        IFS=',' read -ra user_list <<< "$users"
        for user in "${user_list[@]}"; do
            user=$(echo "$user" | xargs)
            if id "$user" &>/dev/null; then
                usermod -a -G "$group_name" "$user"
                success "Usuário $user adicionado ao grupo $group_name"
            fi
        done
    fi
}

# Reiniciar serviço SSH
restart_ssh_service() {
    info "Reiniciando serviço SSH..."
    
    # Detectar sistema de init
    if command -v systemctl &>/dev/null; then
        systemctl restart sshd
    elif command -v service &>/dev/null; then
        service ssh restart
    else
        fatal "Não foi possível reiniciar o serviço SSH"
    fi
    
    # Verificar se o serviço está rodando
    sleep 2
    if command -v systemctl &>/dev/null; then
        if systemctl is-active --quiet sshd; then
            success "Serviço SSH reiniciado com sucesso"
        else
            fatal "Falha ao reiniciar serviço SSH"
        fi
    fi
}

# Testar conectividade SSH
test_ssh_connectivity() {
    local port="${SSH_HARDENING_CONFIG[Port]}"
    
    info "Testando conectividade SSH na porta $port..."
    
    if nc -z localhost "$port" 2>/dev/null; then
        success "SSH está respondendo na porta $port"
    else
        error "SSH não está respondendo na porta $port"
        warn "Verifique as configurações de firewall"
    fi
}

# Função principal
main() {
    info "Iniciando hardening SSH..."
    
    # Validações iniciais
    require_root
    validate_os
    validate_dependencies "sshd" "nc"
    validate_config_file "$SSHD_CONFIG"
    
    # Processar argumentos
    parse_arguments "$@"
    
    # Modo de restauração
    if [[ -n "${RESTORE_BACKUP:-}" ]]; then
        restore_backup "$RESTORE_BACKUP" "$SSHD_CONFIG"
        restart_ssh_service
        test_ssh_connectivity
        success "Backup restaurado com sucesso"
        exit 0
    fi
    
    # Modo apenas backup
    if [[ "${BACKUP_ONLY:-false}" == "true" ]]; then
        backup_file "$SSHD_CONFIG"
        exit 0
    fi
    
    # Validar configuração atual
    validate_ssh_config
    
    # Verificar chaves SSH
    check_user_ssh_keys
    
    # Configurar grupo SSH
    setup_ssh_group
    
    # Aplicar configuração
    apply_ssh_config
    
    # Reiniciar serviço (apenas se não for dry-run)
    if [[ "${DRY_RUN:-false}" != "true" ]]; then
        restart_ssh_service
        test_ssh_connectivity
    fi
    
    success "Hardening SSH concluído com sucesso!"
    
    # Mostrar próximos passos
    info "Próximos passos recomendados:"
    info "1. Teste a conectividade SSH em uma nova sessão"
    info "2. Configure fail2ban para proteção adicional"
    info "3. Configure monitoramento de logs SSH"
    
    # Limpeza de backups antigos
    cleanup_old_backups
}

# Tratamento de sinais
trap 'fatal "Script interrompido pelo usuário"' INT TERM

# Executar apenas se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi