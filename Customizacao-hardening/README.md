
# 🛡️ Customização e Hardening - Servidores Linux

[![CI](https://github.com/rafaelmarzulo/customizacao-hardening/actions/workflows/CI.yml/badge.svg)](https://github.com/rafaelmarzulo/customizacao-hardening/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/rafaelmarzulo/customizacao-hardening/releases)
[![Shell](https://img.shields.io/badge/shell-bash-blue.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://www.linux.org/)
[![Security](https://img.shields.io/badge/security-hardening-red.svg)](https://github.com/rafaelmarzulo/customizacao-hardening)

Este repositório contém uma coleção de scripts para fortalecer a segurança e personalização de servidores Linux, com foco em ambientes corporativos.

## 📁 Estrutura do Projeto

- `scripts/`: Scripts organizados por função (backup, hardening, logs, validações, etc.)
- `configs/`: Arquivos de configuração usados pelos scripts
- `docs/`: Documentação complementar
- `tests/`: Casos de teste e exemplos de uso
- `Makefile`: Automatização de tarefas (instalação, execução, etc.)

## 🚀 Funcionalidades Principais

- Hardening do SSH (desativa root login, autenticação por senha, etc.)
- Backup e restauração de configurações
- Validação e logs detalhados
- Modularização dos scripts para reutilização e manutenção simplificada

## 🧪 Como Usar

```bash
git clone https://github.com/rafaelmarzulo/Customizacao-hardening.git
cd Customizacao-hardening
make install
```

Ou execute scripts diretamente:

```bash
bash scripts/ssh_hardening.sh --help
```

## 🛠️ Requisitos

- Distribuição Linux compatível (Ubuntu 20.04+, Debian 11+)
- Bash 4+
- Permissões administrativas (sudo)

## 🤝 Contribuições

Contribuições são bem-vindas! Veja o arquivo [CONTRIBUTING.md](CONTRIBUTING.md) para mais detalhes.

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.