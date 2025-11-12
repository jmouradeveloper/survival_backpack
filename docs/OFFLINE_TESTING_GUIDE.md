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

## 📱 Teste de Instalação PWA

### Passo 1: Validar Manifest

1. Abra DevTools → **Application** → **Manifest**
2. Verifique se o manifest está carregado corretamente:
   ```
   ✅ Name: Survival Backpack - Gerenciamento de Estoque
   ✅ Short name: Survival Backpack
   ✅ Start URL: /
   ✅ Display: standalone
   ✅ Icons: 192x192, 512x512 (any e maskable)
   ✅ Theme color: #2563eb
   ✅ Background color: #f8fafc
   ```
3. Clique em cada ícone para verificar se carrega

### Passo 2: Verificar Installability

No Chrome DevTools → **Application** → **Manifest**, procure por:

```
✅ "Installability" - deve mostrar "Installable"
```

Se não estiver instalável, verifique:
- [ ] Service Worker está registrado e ativo
- [ ] Manifest está presente e válido
- [ ] Site está sendo servido via HTTPS ou localhost
- [ ] Ícones estão acessíveis
- [ ] Start URL está acessível

### Passo 3: Testar Instalação no iOS (Safari)

**Device:** iPhone ou iPad  
**Browser:** Safari (OBRIGATÓRIO)

1. Acesse o site no Safari
2. Toque no botão **Compartilhar** ⎋ (barra inferior)
3. Role e toque em **"Adicionar à Tela de Início"**
4. Edite o nome se desejar
5. Toque em **"Adicionar"**
6. ✅ Verifique se o ícone apareceu na tela inicial
7. ✅ Abra o app pelo ícone
8. ✅ Deve abrir em tela cheia (sem barra do Safari)
9. ✅ Teste navegação e funcionalidade offline

**Notas iOS:**
- Service Workers funcionam no iOS 11.3+
- PWA só funciona no Safari (não Chrome/Firefox)
- Não aparece na App Library ou busca do sistema
- Cache é limitado (alguns MB)

### Passo 4: Testar Instalação no Android (Chrome)

**Device:** Smartphone ou tablet Android  
**Browser:** Chrome (recomendado) ou Edge

1. Acesse o site no Chrome
2. Deve aparecer banner: **"Adicionar Survival Backpack à tela inicial"**
   - Se não aparecer, use o menu ⋮ → **"Instalar app"**
3. Toque em **"Instalar"** ou **"Adicionar"**
4. ✅ Ícone aparece na tela inicial
5. ✅ Ícone aparece na gaveta de apps
6. ✅ Abra o app pelo ícone
7. ✅ Deve abrir em tela cheia (modo standalone)
8. ✅ Aparece na lista de apps instalados (Configurações → Apps)
9. ✅ Teste navegação e funcionalidade offline

**Notas Android:**
- Melhor suporte a PWA
- App aparece como instalado no sistema
- Pode receber push notifications mesmo fechado
- Cache mais generoso

### Passo 5: Testar Instalação no Desktop

**Browsers suportados:**
- ✅ Chrome 73+ (Windows, Mac, Linux, ChromeOS)
- ✅ Edge 79+ (Windows, Mac)
- ✅ Opera 60+
- ❌ Safari (Mac) - não suporta instalação
- ❌ Firefox - não suporta instalação (ainda)

**Instalação no Chrome/Edge:**

1. Acesse o site
2. Procure o ícone de instalação na barra de endereço:
   - Chrome: **⊕** ou **🖥️** (canto direito)
   - Edge: **⊕** (canto direito)
3. Clique no ícone
4. Clique em **"Instalar"** ou **"Instalar Survival Backpack"**
5. ✅ App abre em janela própria
6. ✅ Aparece no menu iniciar
7. ✅ Aparece na lista de aplicativos
8. ✅ Pode ser fixado na barra de tarefas

**Método alternativo:**
- Menu ⋮ → **"Instalar Survival Backpack"**
- Atalho: Ctrl+Shift+A (Cmd+Shift+A no Mac)

**Teste funcionalidades:**
- ✅ Janela própria (sem barra de URL)
- ✅ Ícone personalizado
- ✅ Funciona offline após cache
- ✅ Notificações desktop

---

## 🔍 Validação de Service Worker

### Verificar Registro

**DevTools → Application → Service Workers**

Verifique:
```
✅ Status: activated and is running
✅ Source: /service-worker
✅ Updated: (timestamp recente)
```

### Verificar Cache

**DevTools → Application → Cache Storage**

Você deve ver:
```
survival-backpack-v2
├── /icon.png
├── /icon.svg
├── / (root)
├── /food_items (se visitado)
├── /assets/application.css
└── /assets/application.js
```

### Testar Atualização de Service Worker

1. Edite `app/views/pwa/service-worker.js`
2. Mude `CACHE_NAME` de `v2` para `v3`
3. Recarregue a página
4. DevTools deve mostrar:
   ```
   🔄 "waiting to activate"
   ```
5. Clique em **"skipWaiting"** ou recarregue novamente
6. ✅ Novo service worker ativado
7. ✅ Cache antigo deletado

### Inspecionar Requisições

**DevTools → Network**

Com service worker ativo, você verá:
- ⚙️ Ícone de engrenagem nas requisições servidas pelo SW
- Cache hits aparecem instantâneos (0ms)

---

## ✅ Checklist Completo de Testes PWA

### Configuração Básica
- [ ] Manifest acessível em `/manifest`
- [ ] Service Worker acessível em `/service-worker`
- [ ] Service Worker registrado com sucesso
- [ ] Meta tags PWA presentes no HTML (`<head>`)
- [ ] Ícones (192x192 e 512x512) acessíveis
- [ ] Theme color configurado

### Installability
- [ ] App aparece como "Installable" no DevTools
- [ ] Banner de instalação aparece (Android Chrome)
- [ ] Ícone de instalação aparece (Desktop Chrome/Edge)
- [ ] "Adicionar à Tela de Início" funciona (iOS Safari)

### Instalação iOS
- [ ] Instala via Safari → Compartilhar → Adicionar à Tela de Início
- [ ] Ícone aparece na tela inicial
- [ ] Abre em tela cheia (sem barra do Safari)
- [ ] Splash screen aparece (com theme color)
- [ ] Funciona offline após cache

### Instalação Android
- [ ] Banner de instalação aparece automaticamente
- [ ] Instala via Chrome → Menu → Instalar app
- [ ] Ícone aparece na tela inicial
- [ ] Ícone aparece na gaveta de apps
- [ ] Aparece como app instalado no sistema
- [ ] Abre em tela cheia (modo standalone)
- [ ] Splash screen aparece
- [ ] Funciona offline após cache

### Instalação Desktop
- [ ] Ícone de instalação aparece na barra de endereço
- [ ] Instala via ícone ou Menu → Instalar
- [ ] Abre em janela própria
- [ ] Aparece no menu iniciar / dock
- [ ] Pode ser fixado na barra de tarefas
- [ ] Funciona offline após cache

### Funcionalidade Offline
- [ ] Páginas já visitadas carregam offline
- [ ] Assets (CSS, JS) funcionam offline
- [ ] Navegação entre páginas cacheadas funciona
- [ ] Mensagem apropriada para páginas não cacheadas
- [ ] Service Worker intercepta requisições corretamente

### Modal de Guia PWA
- [ ] Modal aparece automaticamente após SW ativo (primeira vez)
- [ ] Modal não aparece se usuário já viu (localStorage)
- [ ] Botão "Ver Guia de Instalação" funciona (Configurações)
- [ ] Abas (iOS/Android/Desktop) funcionam
- [ ] Checkbox "Não mostrar novamente" funciona
- [ ] Modal fecha corretamente

### Push Notifications
- [ ] Permissão de notificação pode ser solicitada
- [ ] Push subscription funciona
- [ ] Notificações aparecem mesmo com app fechado
- [ ] Clicar em notificação abre o app
- [ ] Notificações funcionam offline (após configuradas)

### Sincronização
- [ ] Cache atualiza quando volta online
- [ ] Dados sincronizam automaticamente
- [ ] Background sync funciona (se suportado)

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

4. **PWA Completo** ✅ **IMPLEMENTADO**
   - Manifest.json configurado ✅
   - Instalável como app ✅
   - Modal de guia para usuários ✅

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs do console
2. Limpe o cache e cookies
3. Teste em modo anônimo
4. Verifique se o Service Worker está ativo
5. Use o checklist acima para diagnóstico

---

**Versão:** 2.0  
**Data:** Novembro 2025  
**Aplicação:** Survival Backpack

