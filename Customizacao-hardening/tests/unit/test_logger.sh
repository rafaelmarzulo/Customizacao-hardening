#!/bin/bash
# scripts/testes/unit/test_logger.sh
# Descrição: Teste unitário para logger.sh
# Autor: Rafael Marzulo
# Versão: 2.0.0
# Data: 09/07/2025


source "../../scripts/utils/logger.sh"

test_info_function() {
    # Testar se função info existe e funciona
    if info "Teste de log"; then
        echo "PASS: info function works"
        return 0
    else
        echo "FAIL: info function failed"
        return 1
    fi
}

# Executar teste
test_info_function