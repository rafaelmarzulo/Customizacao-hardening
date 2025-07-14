# 📦 Changelog - Customização & Hardening

Todas as mudanças importantes neste projeto serão documentadas aqui.
## [2025-07-12] Correção de Makefile

### Corrigido
- Verificação da existência do diretório `configs/` antes de copiar com `cp -r`, evitando erro quando o diretório não existe.
- Corrigida duplicação de diretório `Customizacao-hardening/Customizacao-hardening/` durante a instalação com `make install`.

🔗 Relacionado à [Issue #5](https://github.com/rafaelmarzulo/Customizacao-hardening/issues/5)

## [2.0.0] - 2025-07-08
### Adicionado
- Estrutura modular com scripts separados (`backup.sh`, `log.sh`, etc.)
- Makefile para automação de tarefas
- `config.yaml` como fonte de configuração central
- Integração com CI e badges no README

## [1.0.0] - 2025-06-30
### Adicionado
- Scripts iniciais para hardening SSH
- Setup básico do servidor com atualizações
- Verificação e envio de configurações do ClamAV
