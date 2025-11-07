# 📴 Guia de Testes Offline - Survival Backpack

## 🎯 Objetivo

Este guia mostra como testar as funcionalidades offline da aplicação Survival Backpack.

---

## 📋 Pré-requisitos

✅ Servidor rodando: `docker compose up`  
✅ Aplicação acessível em: http://localhost:3000  
✅ Navegador moderno (Chrome, Firefox, Edge, Safari)

---

## 🔧 Preparação para Testes

### 1. **Habilitar o Service Worker**

O Service Worker já está configurado! As seguintes mudanças foram feitas:

- ✅ Rotas habilitadas em `config/routes.rb`
- ✅ Service Worker registrado em `app/views/layouts/application.html.erb`
- ✅ Cache configurado em `app/views/pwa/service-worker.js`

### 2. **Reiniciar o Servidor**

```bash
docker compose restart web
```

---

## 🧪 Método 1: Testar no Chrome DevTools (Recomendado)

### Passo 1: Abrir o Navegador
1. Acesse: http://localhost:3000
2. Abra o DevTools (F12 ou Ctrl+Shift+I / Cmd+Option+I)

### Passo 2: Verificar o Service Worker
1. Vá para a aba **"Application"** (ou "Aplicativo")
2. No menu lateral, clique em **"Service Workers"**
3. Você deve ver:
   ```
   ✅ http://localhost:3000/service-worker
   Status: activated and is running
   ```

### Passo 3: Navegar e Cachear
1. Com a aba **"Application"** aberta, vá em **"Cache Storage"**
2. Navegue pela aplicação (página inicial, ver alimentos, etc.)
3. Observe os recursos sendo cacheados
4. Você verá algo como:
   ```
   survival-backpack-v1
   ├── http://localhost:3000/
   ├── http://localhost:3000/food_items
   ├── http://localhost:3000/assets/application.css
   └── http://localhost:3000/assets/application.js
   ```

### Passo 4: Simular Modo Offline
1. Na aba **"Application"**, marque a checkbox **"Offline"**
   
   OU
   
2. Na aba **"Network"**, selecione **"Offline"** no dropdown

### Passo 5: Testar Funcionalidades Offline
1. Recarregue a página (F5)
2. ✅ A página deve carregar normalmente do cache
3. ✅ CSS e JavaScript devem funcionar
4. ✅ Você deve ver os alimentos já carregados
5. ⚠️ Criar/editar/deletar NÃO funcionará (API não disponível offline)

### Passo 6: Voltar Online
1. Desmarque **"Offline"**
2. A aplicação volta a funcionar normalmente

---

## 🧪 Método 2: Testar Offline Real (Sem Internet)

### Passo 1: Preparar o Cache
1. Acesse http://localhost:3000 com internet
2. Navegue por todas as páginas que deseja testar
3. Aguarde 10 segundos para garantir que tudo foi cacheado

### Passo 2: Desconectar a Internet
- **Wi-Fi**: Desabilite o Wi-Fi
- **Ethernet**: Desconecte o cabo
- **Modo Avião**: Ative no notebook/tablet

### Passo 3: Testar
1. Recarregue a página (F5)
2. ✅ Deve funcionar normalmente
3. Navegue entre as páginas já visitadas

### Passo 4: Reconectar
1. Reconecte à internet
2. A aplicação sincroniza automaticamente

---

## 🧪 Método 3: Testar em Dispositivo Móvel

### Passo 1: Descobrir o IP da Máquina

```bash
# Linux/Mac
hostname -I | awk '{print $1}'

# Ou
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Passo 2: Acessar no Mobile
1. Conecte o celular na mesma rede Wi-Fi
2. Acesse: http://SEU_IP:3000
3. Exemplo: http://192.168.1.100:3000

### Passo 3: Testar Offline
1. Navegue pela aplicação
2. Ative o **Modo Avião** no celular
3. Recarregue a página
4. ✅ Deve funcionar do cache

---

## ✅ O Que Funciona Offline

### ✔️ Funcionalidades Disponíveis Offline:

1. **Visualização de Páginas Cacheadas**
   - Página inicial
   - Lista de alimentos (últimos visitados)
   - Detalhes de alimentos (já carregados)

2. **Assets**
   - CSS (estilos)
   - JavaScript (funcionalidades)
   - Ícones e imagens

3. **Navegação**
   - Links entre páginas cacheadas
   - Turbo navigation

### ❌ Funcionalidades NÃO Disponíveis Offline:

1. **Operações de Escrita**
   - ❌ Criar novos alimentos
   - ❌ Editar alimentos
   - ❌ Deletar alimentos

2. **Requisições API**
   - ❌ Buscar novos dados
   - ❌ Estatísticas em tempo real

3. **CDN Externa**
   - ❌ Flatpickr (carrega do CDN)
   - ❌ Precisa ser visitado online primeiro

---

## 🔍 Verificar Status do Service Worker

### No Console do Navegador

```javascript
// Verificar se está registrado
navigator.serviceWorker.getRegistrations().then(registrations => {
  console.log('Service Workers registrados:', registrations.length);
});

// Verificar status
navigator.serviceWorker.ready.then(registration => {
  console.log('Service Worker pronto:', registration.active.state);
});

// Ver cache
caches.keys().then(keys => {
  console.log('Caches disponíveis:', keys);
});
```

---

## 🐛 Troubleshooting

### Problema: Service Worker não registra

**Solução:**
1. Verifique o console do navegador (F12)
2. Procure por erros na aba "Console"
3. Service Workers só funcionam em:
   - HTTPS (produção)
   - localhost (desenvolvimento)

### Problema: Cache não está sendo usado

**Solução:**
1. Abra DevTools → Application → Clear storage
2. Clique em "Clear site data"
3. Recarregue a página
4. Navegue novamente para cachear

### Problema: "Offline" mas não carrega

**Solução:**
1. Certifique-se de ter visitado a página ONLINE primeiro
2. O cache só funciona para páginas já visitadas
3. Limpe o cache e tente novamente

### Problema: Service Worker antigo

**Solução:**
```javascript
// No console do navegador
navigator.serviceWorker.getRegistrations().then(registrations => {
  registrations.forEach(reg => reg.unregister());
  location.reload();
});
```

---

## 📊 Testar Cache Manualmente

### Ver o que está cacheado:

```javascript
caches.open('survival-backpack-v1').then(cache => {
  cache.keys().then(keys => {
    console.log('Arquivos cacheados:');
    keys.forEach(request => console.log('-', request.url));
  });
});
```

### Adicionar ao cache manualmente:

```javascript
caches.open('survival-backpack-v1').then(cache => {
  cache.add('/food_items/1');
  console.log('Adicionado ao cache!');
});
```

---

## 🎯 Checklist de Teste Completo

### Preparação
- [ ] Servidor rodando
- [ ] Aplicação aberta no navegador
- [ ] DevTools aberto na aba "Application"
- [ ] Service Worker visível e "activated"

### Teste Online
- [ ] Navegar pela página inicial
- [ ] Ver lista de alimentos
- [ ] Abrir detalhes de alguns alimentos
- [ ] Verificar Cache Storage no DevTools

### Teste Offline
- [ ] Marcar "Offline" no DevTools
- [ ] Recarregar a página (F5)
- [ ] Página inicial carrega do cache
- [ ] Navegação entre páginas visitadas funciona
- [ ] CSS e JavaScript funcionam
- [ ] Tentar criar novo alimento (deve falhar graciosamente)

### Volta Online
- [ ] Desmarcar "Offline"
- [ ] Funcionalidades completas voltam
- [ ] API funciona novamente

---

## 📝 Logs Úteis

### Logs do Service Worker:

No console do navegador, você deve ver:

```
Service Worker registrado com sucesso: ServiceWorkerRegistration {...}
Caching essential assets
```

Quando navegar offline:
```
Offline - Resource not available (para recursos não cacheados)
```

---

## 🚀 Melhorias Futuras

Para tornar a aplicação **totalmente funcional offline**, seria necessário:

1. **IndexedDB**
   - Armazenar dados localmente
   - Sincronizar quando voltar online

2. **Background Sync**
   - Fila de operações offline
   - Sincronização automática

3. **Cache Dinâmico**
   - Cache de API responses
   - Estratégias de atualização

4. **PWA Completo**
   - Manifest.json configurado
   - Instalável como app

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs do console
2. Limpe o cache e cookies
3. Teste em modo anônimo
4. Verifique se o Service Worker está ativo

---

**Versão:** 1.0  
**Data:** Novembro 2025  
**Aplicação:** Survival Backpack

