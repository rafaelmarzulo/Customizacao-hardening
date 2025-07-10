#!/bin/bash
# scripts/utils/validator.sh
# Descrição: Funções de validação
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Validar se é root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        fatal "Este script deve ser executado como root (use sudo)"
    fi
    debug "Validação de root: OK"
}

# Validar sistema operacional
validate_os() {
    local supported_os=("ubuntu" "debian" "centos" "rhel")
    local current_os
    
    if [[ -f /etc/os-release ]]; then
        current_os=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    else
        fatal "Não foi possível detectar o sistema operacional"
    fi
    
    for os in "${supported_os[@]}"; do
        if [[ "$current_os" == "$os" ]]; then
            info "Sistema operacional suportado: $current_os"
            return 0
        fi
    done
    
    fatal "Sistema operacional não suportado: $current_os"
}

# Validar conectividade de rede
validate_network() {
    local test_hosts=("8.8.8.8" "1.1.1.1")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 5 "$host" &>/dev/null; then
            debug "Conectividade de rede: OK ($host)"
            return 0
        fi
    done
    
    warn "Sem conectividade de rede detectada"
    return 1
}

# Validar espaço em disco
validate_disk_space() {
    local required_space="${1:-1000000}" # 1GB em KB por padrão
    local available_space
    
    available_space=$(df / | awk 'NR==2 {print $4}')
    
    if [[ $available_space -lt $required_space ]]; then
        fatal "Espaço insuficiente em disco. Necessário: ${required_space}KB, Disponível: ${available_space}KB"
    fi
    
    debug "Espaço em disco: OK (${available_space}KB disponível)"
}

# Validar dependências
validate_dependencies() {
    local dependencies=("$@")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Dependências não encontradas: ${missing_deps[*]}"
        info "Instale com: apt install ${missing_deps[*]} # Ubuntu/Debian"
        info "Instale com: yum install ${missing_deps[*]} # CentOS/RHEL"
        return 1
    fi
    
    debug "Todas as dependências estão instaladas"
}

# Validar arquivo de configuração
validate_config_file() {
    local config_file="$1"
    
    [[ -z "$config_file" ]] && fatal "Arquivo de configuração não especificado"
    [[ ! -f "$config_file" ]] && fatal "Arquivo de configuração não encontrado: $config_file"
    [[ ! -r "$config_file" ]] && fatal "Arquivo de configuração não é legível: $config_file"
    
    debug "Arquivo de configuração válido: $config_file"
}

# Validar porta
validate_port() {
    local port="$1"
    
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [[ $port -lt 1 ]] || [[ $port -gt 65535 ]]; then
        fatal "Porta inválida: $port (deve ser entre 1-65535)"
    fi
    
    debug "Porta válida: $port"
}

# Validar endereço IP
validate_ip() {
    local ip="$1"
    local ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ ! "$ip" =~ $ip_regex ]]; then
        fatal "Endereço IP inválido: $ip"
    fi
    
    # Validar cada octeto
    IFS='.' read -ra octets <<< "$ip"
    for octet in "${octets[@]}"; do
        if [[ $octet -gt 255 ]]; then
            fatal "Endereço IP inválido: $ip (octeto $octet > 255)"
        fi
    done
    
    debug "Endereço IP válido: $ip"
}