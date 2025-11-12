# 🐳 Docker Scripts - Referência Rápida

Este documento fornece uma referência rápida de todos os scripts Docker disponíveis no projeto.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Scripts Disponíveis](#scripts-disponíveis)
- [Fluxos de Trabalho Comuns](#fluxos-de-trabalho-comuns)
- [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

Todos os scripts Docker estão localizados em `bin/` e seguem o padrão `docker-*`.

### Instalação Inicial
```bash
./bin/docker-setup
```

### Uso Diário
```bash
./bin/docker-up      # Iniciar
./bin/docker-logs    # Monitorar
./bin/docker-test    # Testar
./bin/docker-stop    # Parar
```

## 📚 Scripts Disponíveis

### 1. docker-setup
**Função:** Setup inicial completo do ambiente Docker

**Uso:**
```bash
./bin/docker-setup
```

**O que faz:**
1. ✅ Verifica se Docker está instalado
2. ✅ Cria diretórios necessários (storage, log, tmp)
3. ✅ Builda a imagem Docker
4. ✅ Inicia os containers
5. ✅ Prepara o banco de dados
6. ✅ Exibe instruções úteis

**Quando usar:**
- Primeira vez configurando o projeto
- Após clonar o repositório
- Após executar `docker-clean` completo

---

### 2. docker-up
**Função:** Inicia a aplicação em modo detached

**Uso:**
```bash
./bin/docker-up
```

**O que faz:**
1. ✅ Verifica se Docker está instalado
2. ✅ Inicia containers em background
3. ✅ Exibe URL de acesso e comandos úteis

**Quando usar:**
- Iniciar o desenvolvimento diário
- Após parar a aplicação com `docker-stop`

**URL de Acesso:** http://localhost:3000

---

### 3. docker-stop
**Função:** Para a aplicação Docker

**Uso:**
```bash
./bin/docker-stop
```

**O que faz:**
1. ✅ Verifica se Docker está instalado
2. ✅ Para os containers (sem removê-los)
3. ✅ Mantém volumes e dados intactos

**Quando usar:**
- Fim do dia de trabalho
- Liberar recursos do sistema
- Antes de fazer manutenção

**Nota:** Dados e volumes são preservados!

---

### 4. docker-logs
**Função:** Visualiza logs dos containers com opções avançadas

**Uso:**
```bash
./bin/docker-logs [OPÇÕES]
```

**Opções Disponíveis:**
```bash
-f, --follow       # Acompanhar logs em tempo real (padrão)
-n, --tail NUM     # Mostrar últimas NUM linhas (padrão: 100)
--all              # Mostrar todos os logs desde início
--no-follow        # Não acompanhar em tempo real
-h, --help         # Mostrar ajuda
```

**Exemplos:**
```bash
# Modo padrão (últimas 100 linhas + follow)
./bin/docker-logs

# Ver últimas 50 linhas + seguir
./bin/docker-logs -n 50

# Ver todos os logs desde o início
./bin/docker-logs --all

# Ver snapshot dos logs (sem follow)
./bin/docker-logs --no-follow

# Ver últimas 200 linhas sem seguir
./bin/docker-logs -n 200 --no-follow
```

**Quando usar:**
- Debugar problemas
- Monitorar requisições
- Acompanhar execução de jobs
- Ver erros em tempo real

**Atalhos:**
- `Ctrl+C` para sair do modo follow

---

### 5. docker-test
**Função:** Executa testes automatizados no container Docker

**Uso:**
```bash
./bin/docker-test [OPÇÕES]
```

**Opções Disponíveis:**
```bash
--all              # Executar todos os testes (padrão)
--models           # Executar apenas testes de models
--controllers      # Executar apenas testes de controllers
--integration      # Executar apenas testes de integração
--system           # Executar testes de sistema
--file PATH        # Executar testes de um arquivo específico
--coverage         # Executar com relatório de cobertura
--verbose          # Modo verbose
-h, --help         # Mostrar ajuda
```

**Exemplos:**
```bash
# Modo padrão (todos os testes)
./bin/docker-test

# Apenas testes de models
./bin/docker-test --models

# Apenas testes de controllers
./bin/docker-test --controllers

# Testes de integração
./bin/docker-test --integration

# Arquivo específico
./bin/docker-test --file test/models/food_item_test.rb

# Com cobertura de código
./bin/docker-test --coverage

# Modo verbose
./bin/docker-test --verbose
```

**O que faz:**
1. ✅ Verifica/inicia container se necessário
2. ✅ Executa testes dentro do container
3. ✅ Exibe resultados formatados
4. ✅ Para container se foi iniciado temporariamente
5. ✅ Retorna código de erro apropriado

**Quando usar:**
- Antes de commit/push
- Após implementar nova feature
- Validar correções de bugs
- Verificar cobertura de código
- Parte do CI/CD

**Vantagens:**
- ✅ Ambiente isolado e consistente
- ✅ Não precisa configurar ambiente local
- ✅ Gerencia container automaticamente
- ✅ Suporte a múltiplas opções
- ✅ Feedback claro de sucesso/falha

---

### 6. docker-exec
**Função:** Executa comandos arbitrários no container Docker

**Uso:**
```bash
./bin/docker-exec [comando e argumentos]
```

**Exemplos:**
```bash
# Executar migrations
./bin/docker-exec bin/rails db:migrate

# Executar seed
./bin/docker-exec bin/rails db:seed

# Executar Rubocop
./bin/docker-exec bin/rubocop

# Executar Brakeman
./bin/docker-exec bin/brakeman

# Instalar gems
./bin/docker-exec bundle install

# Gerar models
./bin/docker-exec bin/rails generate model User name:string

# Listar arquivos
./bin/docker-exec ls -la app/models

# Executar rake tasks
./bin/docker-exec bin/rails db:rollback

# Qualquer comando shell
./bin/docker-exec pwd
```

**O que faz:**
1. ✅ Verifica se container está rodando
2. ✅ Executa o comando fornecido dentro do container
3. ✅ Passa todos os argumentos corretamente
4. ✅ Retorna código de saída do comando

**Quando usar:**
- Executar comandos Rails arbitrários
- Rodar migrations ou seeds
- Executar linters (rubocop, brakeman)
- Gerar código (models, controllers, migrations)
- Instalar dependências
- Executar scripts customizados
- Qualquer comando que precise rodar no container

**Vantagens:**
- ✅ Versátil e genérico
- ✅ Suporta qualquer comando
- ✅ Passa argumentos corretamente
- ✅ Interface simples e intuitiva

---

### 7. docker-console
**Função:** Abre console Rails dentro do container

**Uso:**
```bash
./bin/docker-console
```

**O que faz:**
1. ✅ Verifica se container está rodando
2. ✅ Abre console Rails interativo
3. ✅ Permite executar comandos Ruby/Rails

**Exemplos de uso no console:**
```ruby
# Verificar quantidade de food items
FoodItem.count

# Criar item de teste
FoodItem.create(name: "Teste", quantity: 1)

# Executar migration
ActiveRecord::Migration.check_pending!

# Limpar cache
Rails.cache.clear
```

**Quando usar:**
- Executar comandos Rails
- Debugar models
- Testar queries
- Executar scripts Ruby

**Atalhos:**
- `exit` ou `Ctrl+D` para sair

---

### 8. docker-clean-cache
**Função:** Limpa cache e logs usando o próprio container (evita problemas de permissão)

**Uso:**
```bash
./bin/docker-clean-cache
```

**O que faz:**
1. ✅ Verifica/inicia container se necessário
2. ✅ Limpa `tmp/cache/*`
3. ✅ Trunca arquivos de log
4. ✅ Para container se foi iniciado temporariamente

**Quando usar:**
- Liberar espaço em disco
- Resolver problemas de cache
- Limpar logs grandes
- Antes de commit/push

**Vantagens:**
- ✅ Sem problemas de permissão
- ✅ Rápido e seguro
- ✅ Não remove containers/volumes

---

### 9. docker-clean
**Função:** Limpeza completa de containers, volumes e imagens

**Uso:**
```bash
./bin/docker-clean
```

**O que faz:**
1. ⚠️ Solicita confirmação do usuário
2. ✅ Para e remove containers
3. ✅ Remove volumes Docker
4. ✅ (Opcional) Remove imagens Docker
5. ✅ (Opcional) Limpa arquivos temporários locais

**Processo Interativo:**
```bash
⚠️  Isso irá remover todos os containers, volumes e dados. Continuar? (y/N)
# Se sim...

Deseja remover também as imagens Docker? (y/N)
# Se sim...

Deseja limpar também os arquivos temporários locais (log, tmp)? (y/N)
# Se sim e houver arquivos com permissões especiais...

Deseja usar sudo para remover esses arquivos? (y/N)
```

**Quando usar:**
- ⚠️ **CUIDADO**: Remove TODOS os dados!
- Reset completo do ambiente
- Resolver problemas graves
- Antes de rebuild completo
- Liberar muito espaço em disco

**Depois de usar:**
```bash
./bin/docker-setup  # Reconfigurar tudo
```

---

## 🔄 Fluxos de Trabalho Comuns

### Desenvolvimento Diário
```bash
# Manhã - Iniciar trabalho
./bin/docker-up
./bin/docker-logs  # Em outro terminal

# Durante o dia - Monitorar
./bin/docker-logs -n 50

# Durante o dia - Executar migrations
./bin/docker-exec bin/rails db:migrate

# Durante o dia - Executar linters
./bin/docker-exec bin/rubocop

# Durante o dia - Testar mudanças
./bin/docker-test --models

# Durante o dia - Console Rails
./bin/docker-console

# Noite - Testar antes de commitar
./bin/docker-test

# Noite - Parar trabalho
./bin/docker-stop
```

### Antes de Commit/Push
```bash
# 1. Executar todos os testes
./bin/docker-test

# 2. Verificar cobertura (opcional)
./bin/docker-test --coverage

# 3. Se tudo passou, commit
git add .
git commit -m "Sua mensagem"
git push
```

### Primeira Vez no Projeto
```bash
# 1. Clone o repositório
git clone [repo-url]
cd survival_backpack

# 2. Setup completo
./bin/docker-setup

# 3. Verificar logs
./bin/docker-logs

# 4. Acessar aplicação
# http://localhost:3000
```

### Debug de Problemas
```bash
# 1. Ver logs em tempo real
./bin/docker-logs --all

# 2. Acessar console para testar
./bin/docker-console

# 3. Limpar cache se necessário
./bin/docker-clean-cache

# 4. Se problema persistir, rebuild
./bin/docker-clean
./bin/docker-setup
```

### Manutenção Semanal
```bash
# Limpar cache e logs
./bin/docker-clean-cache

# Verificar saúde da aplicação
./bin/docker-logs --no-follow
```

### Reset Completo
```bash
# 1. Limpeza total
./bin/docker-clean
# Responder 'y' para todas as perguntas

# 2. Rebuild
./bin/docker-setup

# 3. Verificar funcionamento
./bin/docker-logs
```

---

## 🔍 Troubleshooting

### Container não inicia
```bash
# Ver logs de erro
./bin/docker-logs --all

# Verificar se porta 3000 está livre
lsof -i :3000

# Rebuild forçado
./bin/docker-clean
./bin/docker-setup
```

### Erro de permissão em arquivos
```bash
# Use docker-clean-cache ao invés de rm direto
./bin/docker-clean-cache

# Ou use docker-clean com sudo
./bin/docker-clean
# Responder 'y' quando perguntar sobre sudo
```

### Banco de dados corrompido
```bash
# No console
./bin/docker-console
rails db:reset

# Ou rebuild completo
./bin/docker-clean
./bin/docker-setup
```

### Container está rodando mas não responde
```bash
# Verificar healthcheck
docker ps

# Ver logs
./bin/docker-logs

# Restart
./bin/docker-stop
./bin/docker-up
```

### Problemas após git pull
```bash
# Rebuild imagem
docker compose build

# Rodar migrations
./bin/docker-exec bin/rails db:migrate

# Ou via console se precisar
./bin/docker-console
# > rails db:migrate
```

### Espaço em disco cheio
```bash
# 1. Limpar cache
./bin/docker-clean-cache

# 2. Se não resolver, limpeza completa
./bin/docker-clean
# Responder 'y' para remover imagens

# 3. Remover imagens órfãs
docker image prune -a
```

---

## 📊 Comparação de Scripts

| Script | Remove Containers | Remove Volumes | Remove Imagens | Remove Logs | Executa Testes | Pede Confirmação |
|--------|------------------|----------------|----------------|-------------|----------------|------------------|
| `docker-up` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `docker-stop` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `docker-logs` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `docker-test` | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `docker-exec` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `docker-console` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `docker-clean-cache` | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| `docker-clean` | ✅ | ✅ | 🟡 Opcional | 🟡 Opcional | ❌ | ✅ |

**Legenda:**
- ✅ Sim
- ❌ Não
- 🟡 Opcional/Condicional

---

## 💡 Dicas e Boas Práticas

### ✨ Produtividade
```bash
# Alias úteis (adicione ao seu ~/.bashrc ou ~/.zshrc)
alias dup='./bin/docker-up'
alias dstop='./bin/docker-stop'
alias dlogs='./bin/docker-logs'
alias dtest='./bin/docker-test'
alias dexec='./bin/docker-exec'
alias dconsole='./bin/docker-console'
```

### 🧪 Testes
```bash
# Sempre testar antes de commit
./bin/docker-test

# Testar apenas o que mudou (mais rápido)
./bin/docker-test --models
./bin/docker-test --controllers

# Verificar cobertura periodicamente
./bin/docker-test --coverage
```

### 🎯 Performance
```bash
# Logs mais rápidos (menos linhas)
./bin/docker-logs -n 20

# Não usar --all em produção (muito lento)

# Testes específicos são mais rápidos
./bin/docker-test --file test/models/food_item_test.rb
```

### 🔐 Segurança
```bash
# Sempre revisar antes de confirmar
./bin/docker-clean  # Leia as mensagens antes de responder

# Não commitar volumes Docker
# (já está no .gitignore)
```

### 📚 Documentação
```bash
# Todos os scripts têm --help
./bin/docker-logs --help
```

---

## 🆘 Comandos de Emergência

### Parar TUDO imediatamente
```bash
docker stop $(docker ps -aq)
```

### Remover TUDO (⚠️ CUIDADO!)
```bash
docker system prune -a --volumes
```

### Verificar uso de disco
```bash
docker system df
```

### Ver containers em execução
```bash
docker ps
```

### Ver todos os containers (inclusive parados)
```bash
docker ps -a
```

---

## 📞 Suporte

Se encontrar problemas não cobertos aqui:

1. 📖 Verifique [DOCKER_DEVELOPMENT.md](DOCKER_DEVELOPMENT.md)
2. 📖 Verifique [README.md](../README.md)
3. 🐛 Abra uma issue no GitHub
4. 💬 Entre em contato com o time

---

**Atualizado:** Novembro 2025  
**Versão:** 1.0.0

