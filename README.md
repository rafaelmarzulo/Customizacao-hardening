# 🛡️ Customização e Hardening - Servidores Linux

[![CI](https://github.com/rafaelmarzulo/Customizacao-hardening/workflows/CI/badge.svg)](https://github.com/rafaelmarzulo/Customizacao-hardening/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/rafaelmarzulo/Customizacao-hardening/releases)
[![Shell](https://img.shields.io/badge/shell-bash-blue.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://www.linux.org/)
[![Security](https://img.shields.io/badge/security-hardening-red.svg)](https://github.com/rafaelmarzulo/Customizacao-hardening)
[![Stars](https://img.shields.io/github/stars/rafaelmarzulo/Customizacao-hardening?style=social)](https://github.com/rafaelmarzulo/Customizacao-hardening/stargazers)

> 🚀 **Solução profissional para fortalecer a segurança de servidores Linux com arquitetura modular e práticas de hardening corporativas.**

---

## 📦 Visão Geral

Este projeto automatiza a customização e o hardening de servidores Linux, promovendo:

- Aplicação de boas práticas de segurança.
- Modularização por scripts e categorias (rede, SSH, antivírus etc).
- Facilidade de manutenção com uso de `Makefile` e `scripts utilitários`.

---

## 🧰 Estrutura do Projeto

```bash
.
├── configs/                # Configurações padrão
├── docs/                   # Documentação do projeto
├── scripts/                # Scripts de automação e segurança
│   ├── hardening/
│   ├── seguranca/
│   ├── setup/
│   └── utils/
├── tests/                  # Testes automatizados
├── Makefile                # Comandos automáticos (make install, validate etc.)
├── README.md               # Este arquivo
└── .github/workflows/      # CI com GitHub Actions
```

---

## 🚀 Como Usar

```bash
# Clone o repositório
git clone git@github.com:rafaelmarzulo/Customizacao-hardening.git

# Acesse o diretório
cd Customizacao-hardening

# Execute o Makefile
make install
```

---

## 📄 Licença

Distribuído sob a licença [MIT](https://opensource.org/licenses/MIT). Veja `LICENSE` para mais informações.

---

## 🤝 Contribuições

Contribuições são bem-vindas! Veja o arquivo [`CONTRIBUTING.md`](CONTRIBUTING.md) para mais detalhes.

---

## 📢 Contato

Desenvolvido por **Rafael Marzulo**  
📧 [rafaelmarzulo@gmail.com](mailto:rafaelmarzulo@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/rafaelmarzulo/)
