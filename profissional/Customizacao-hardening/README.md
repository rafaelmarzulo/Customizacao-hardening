# 🛡️ Customização e Hardening - Servidores Linux

Este repositório contém uma coleção de scripts para fortalecer a segurança e personalização de servidores Linux, com foco em ambientes corporativos.

## 📁 Estrutura dos Scripts

### 🔐 `hardening_ssh_local.sh`
- Aplica boas práticas no `sshd_config` local
- Reforça a segurança do acesso remoto via SSH:
  - Desabilita login root
  - Habilita autenticação por chave pública
  - Valida existência de chave em `~/.ssh/`

### 🛠️ `server_setup.sh`
- Script de configuração inicial do servidor:
  - Atualizações de pacotes
  - Configurações básicas de rede
  - Instalação de pacotes essenciais

### 🧪 `clamav-all`
- Script auxiliar para validação de ameaças com ClamAV
- Usado para varredura e análise completa de diretórios do sistema

### 🐚 `clamscan_daily.sh`
- Agendamento de varredura diária com `clamscan`
- Ideal para uso com `cron`
- Gera logs e envia alertas (pode ser estendido)

### 📤 `envio_config_clamav.sh`
- Responsável por aplicar e enviar configurações do ClamAV
- Inclui ajustes em `freshclam.conf`, `clamd.conf`, etc.

---

## 🚀 Como usar

```bash
chmod +x *.sh
./server_setup.sh
./hardening_ssh_local.sh
```

> ⚠️ Execute como root (`sudo`) para aplicar configurações no sistema.

---

## ✅ Requisitos

- Ubuntu Server 22.04 ou 24.04
- SSH configurado
- ClamAV instalado (`apt install clamav`)

---

## 📜 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

## 🙋‍♂️ Autor

**Rafael Marzulo**  
[GitHub: @rafaelmarzulo](https://github.com/rafaelmarzulo)
