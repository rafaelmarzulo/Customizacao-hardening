#!/bin/bash
# scripts/tests/test_runner.sh
# Descrição: Sistema de testes automatizados
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025

set -euo pipefail

readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Cores para output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Contadores
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Função de teste
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -n "Executando: $test_name ... "
    ((TESTS_RUN++))
    
    if $test_function; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

# Testes unitários
test_logger_functions() {
    source "$PROJECT_ROOT/scripts/utils/logger.sh"
    
    # Testar se funções existem
    [[ $(type -t info) == "function" ]] || return 1
    [[ $(type -t error) == "function" ]] || return 1
    [[ $(type -t success) == "function" ]] || return 1
    
    return 0
}

test_validator_functions() {
    source "$PROJECT_ROOT/scripts/utils/validator.sh"
    
    # Testar validação de porta
    validate_port 22 || return 1
    validate_port 80 || return 1
    
    # Testar porta inválida (deve falhar)
    if validate_port 70000 2>/dev/null; then
        return 1  # Deveria ter falhado
    fi
    
    return 0
}

test_backup_functions() {
    source "$PROJECT_ROOT/scripts/utils/backup.sh"
    
    # Criar arquivo temporário para teste
    local temp_file=$(mktemp)
    echo "teste" > "$temp_file"
    
    # Testar backup
    local backup_file
    backup_file=$(backup_file "$temp_file" "test_file")
    
    # Verificar se backup foi criado
    [[ -f "$backup_file" ]] || return 1
    
    # Limpeza
    rm -f "$temp_file" "$backup_file" "${backup_file}.sha256"
    
    return 0
}

# Testes de integração
test_ssh_hardening_dry_run() {
    local ssh_script="$PROJECT_ROOT/scripts/hardening/ssh_hardening.sh"
    
    # Verificar se script existe
    [[ -f "$ssh_script" ]] || return 1
    
    # Testar dry-run (não deve modificar nada)
    if sudo "$ssh_script" --dry-run &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Executar todos os testes
main() {
    echo "=== Executando Testes ==="
    echo
    
    # Testes unitários
    echo "Testes Unitários:"
    run_test "Logger Functions" test_logger_functions
    run_test "Validator Functions" test_validator_functions
    run_test "Backup Functions" test_backup_functions
    
    echo
    
    # Testes de integração
    echo "Testes de Integração:"
    run_test "SSH Hardening Dry Run" test_ssh_hardening_dry_run
    
    echo
    echo "=== Resultados ==="
    echo "Total: $TESTS_RUN"
    echo -e "Passou: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Falhou: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Todos os testes passaram!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Alguns testes falharam!${NC}"
        exit 1
    fi
}

main "$@"