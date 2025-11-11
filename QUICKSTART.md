# ⚡ Quick Start - Survival Backpack

Guia rápido para começar a desenvolver em **menos de 5 minutos**!

## 🚀 Setup Rápido (3 passos)

### 1️⃣ Clone e Entre no Projeto
```bash
git clone https://github.com/seu-usuario/survival_backpack.git
cd survival_backpack
```

### 2️⃣ Execute o Setup Docker
```bash
./bin/docker-setup
```

### 3️⃣ Acesse a Aplicação
```
http://localhost:3000
```

🎉 **Pronto!** Você está desenvolvendo!

---

## 📝 Comandos do Dia a Dia

```bash
# 🚀 Iniciar aplicação
./bin/docker-up

# 📜 Ver logs
./bin/docker-logs

# 🧪 Executar testes
./bin/docker-test

# 💻 Console Rails
./bin/docker-console

# 🛑 Parar aplicação
./bin/docker-stop

# 🧹 Limpar cache
./bin/docker-clean-cache
```

---

## 🎯 Tarefas Comuns

### Ver Últimos Logs
```bash
./bin/docker-logs -n 50
```

### Executar Migration
```bash
./bin/docker-console
rails db:migrate
exit
```

### Executar Testes
```bash
# Todos os testes
./bin/docker-test

# Apenas models
./bin/docker-test --models

# Com cobertura
./bin/docker-test --coverage
```

### Reset do Banco de Dados
```bash
./bin/docker-console
rails db:reset
exit
```

---

## 📚 Próximos Passos

1. 📖 Leia o [README completo](README.md)
2. 🐳 Veja a [Referência de Scripts Docker](docs/DOCKER_SCRIPTS_REFERENCE.md)
3. 🔄 Aprenda sobre [Sistema FIFO](docs/FIFO_QUICKSTART.md)
4. 🔔 Configure [Notificações](docs/NOTIFICATIONS_QUICKSTART.md)
5. 🌐 Explore a [API](docs/API_DOCUMENTATION.md)

---

## 🆘 Problemas?

### Container não inicia
```bash
./bin/docker-logs --all
```

### Reset completo
```bash
./bin/docker-clean
./bin/docker-setup
```

### Mais ajuda
- 📖 [Documentação Completa](docs/INDEX.md)
- 🐛 [GitHub Issues](https://github.com/seu-usuario/survival_backpack/issues)

---

**Tempo médio de setup:** ⏱️ 3-5 minutos  
**Dificuldade:** 🟢 Muito Fácil

🎒 **Happy Coding!**
