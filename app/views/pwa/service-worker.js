const CACHE_NAME = 'survival-backpack-v1';
const OFFLINE_URL = '/offline.html';

// Assets essenciais para funcionar offline
const ESSENTIAL_ASSETS = [
  '/',
  '/food_items',
  '/assets/application.css',
  '/assets/application.js'
];

// Instalar Service Worker e fazer cache dos assets essenciais
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('Caching essential assets');
      return cache.addAll(ESSENTIAL_ASSETS);
    })
  );
  self.skipWaiting();
});

// Ativar Service Worker e limpar caches antigos
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  return self.clients.claim();
});

// Interceptar requisições e servir do cache quando offline
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Ignorar requisições não-GET
  if (request.method !== 'GET') {
    return;
  }

  // Ignorar requisições de outros domínios
  if (url.origin !== location.origin) {
    return;
  }

  // Estratégia: Network First, fallback para Cache
  event.respondWith(
    fetch(request)
      .then((response) => {
        // Se a resposta é válida, clonar e guardar no cache
        if (response && response.status === 200) {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(request, responseToCache);
          });
        }
        return response;
      })
      .catch(() => {
        // Se falhar (offline), tentar buscar do cache
        return caches.match(request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }

          // Se é navegação e não tem no cache, retornar página offline
          if (request.mode === 'navigate') {
            return caches.match(OFFLINE_URL);
          }

          // Para outros recursos, retornar erro
          return new Response('Offline - Resource not available', {
            status: 503,
            statusText: 'Service Unavailable'
          });
        });
      })
  );
});

// Sincronização em background (quando voltar online)
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-food-items') {
    event.waitUntil(syncFoodItems());
  }
});

async function syncFoodItems() {
  try {
    // Buscar dados pendentes do IndexedDB
    const pendingData = await getPendingSyncData();
    
    for (const item of pendingData) {
      const response = await fetch('/api/v1/food_items', {
        method: item.method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(item.data)
      });

      if (response.ok) {
        await removeSyncData(item.id);
      }
    }
  } catch (error) {
    console.error('Sync failed:', error);
  }
}

// Placeholder functions - implementar com IndexedDB se necessário
async function getPendingSyncData() {
  return [];
}

async function removeSyncData(id) {
  return true;
}

// Add a service worker for processing Web Push notifications:
//
// self.addEventListener("push", async (event) => {
//   const { title, options } = await event.data.json()
//   event.waitUntil(self.registration.showNotification(title, options))
// })
//
// self.addEventListener("notificationclick", function(event) {
//   event.notification.close()
//   event.waitUntil(
//     clients.matchAll({ type: "window" }).then((clientList) => {
//       for (let i = 0; i < clientList.length; i++) {
//         let client = clientList[i]
//         let clientPath = (new URL(client.url)).pathname
//
//         if (clientPath == event.notification.data.path && "focus" in client) {
//           return client.focus()
//         }
//       }
//
//       if (clients.openWindow) {
//         return clients.openWindow(event.notification.data.path)
//       }
//     })
//   )
// })
