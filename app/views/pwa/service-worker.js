const CACHE_NAME = 'survival-backpack-v2';
const OFFLINE_URL = '/offline.html';
const NOTIFICATIONS_DB_NAME = 'notifications-db';
const NOTIFICATIONS_STORE_NAME = 'notifications';

// Assets essenciais para funcionar offline
// Não incluir páginas HTML no cache inicial, apenas assets estáticos
const ESSENTIAL_ASSETS = [
  '/icon.png',
  '/icon.svg'
];

// Instalar Service Worker e fazer cache dos assets essenciais
self.addEventListener('install', (event) => {
  console.log('Service Worker: Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('Service Worker: Caching essential assets');
      // Cachear assets um por um para não falhar todos se um der erro
      return Promise.allSettled(
        ESSENTIAL_ASSETS.map(url => {
          return cache.add(url).catch(err => {
            console.warn(`Failed to cache ${url}:`, err);
          });
        })
      );
    }).then(() => {
      console.log('Service Worker: Installation complete');
    })
  );
  self.skipWaiting();
});

// Ativar Service Worker e limpar caches antigos
self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activating...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('Service Worker: Activation complete');
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

// ==================== PUSH NOTIFICATIONS ====================

// Receber e exibir Push Notifications
self.addEventListener('push', async (event) => {
  console.log('Push notification received');
  
  let notificationData = {
    title: 'Notificação',
    body: 'Você tem uma nova notificação',
    icon: '/icon.png',
    badge: '/icon.png',
    data: { path: '/notifications' }
  };

  try {
    if (event.data) {
      const data = event.data.json();
      notificationData = {
        title: data.title || notificationData.title,
        body: data.body || notificationData.body,
        icon: data.icon || notificationData.icon,
        badge: data.badge || notificationData.badge,
        tag: data.tag || 'notification',
        requireInteraction: data.priority >= 2, // Alta prioridade requer interação
        data: {
          path: data.path || '/notifications',
          notificationId: data.id
        }
      };
    }

    // Armazenar notificação no IndexedDB para acesso offline
    await storeNotificationOffline(notificationData);

  } catch (error) {
    console.error('Error parsing push notification:', error);
  }

  event.waitUntil(
    self.registration.showNotification(notificationData.title, {
      body: notificationData.body,
      icon: notificationData.icon,
      badge: notificationData.badge,
      tag: notificationData.tag,
      requireInteraction: notificationData.requireInteraction,
      data: notificationData.data,
      actions: [
        { action: 'view', title: 'Ver detalhes' },
        { action: 'dismiss', title: 'Dispensar' }
      ]
    })
  );
});

// Lidar com cliques em notificações
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'dismiss') {
    return;
  }

  const urlToOpen = event.notification.data.path || '/notifications';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // Verificar se já existe uma janela aberta
      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i];
        let clientPath = (new URL(client.url)).pathname;

        if (clientPath === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }

      // Se não há janela aberta, abrir uma nova
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );

  // Marcar notificação como lida (se online)
  if (event.notification.data.notificationId) {
    markNotificationAsRead(event.notification.data.notificationId);
  }
});

// ==================== BACKGROUND SYNC ====================

// Sincronização em background (quando voltar online)
self.addEventListener('sync', (event) => {
  console.log('Background sync triggered:', event.tag);
  
  if (event.tag === 'sync-food-items') {
    event.waitUntil(syncFoodItems());
  } else if (event.tag === 'sync-notifications') {
    event.waitUntil(syncNotifications());
  } else if (event.tag === 'check-expirations') {
    event.waitUntil(checkExpirationsOffline());
  }
});

// ==================== PERIODIC BACKGROUND SYNC ====================

// Verificar validades periodicamente (mesmo offline)
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'check-expirations') {
    event.waitUntil(checkExpirationsOffline());
  }
});

// ==================== HELPER FUNCTIONS ====================

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

async function syncNotifications() {
  try {
    const response = await fetch('/api/v1/notifications');
    if (response.ok) {
      const data = await response.json();
      // Atualizar cache de notificações
      const cache = await caches.open(CACHE_NAME);
      await cache.put('/api/v1/notifications', new Response(JSON.stringify(data)));
    }
  } catch (error) {
    console.error('Notification sync failed:', error);
  }
}

// Verificar validades mesmo offline usando dados em cache
async function checkExpirationsOffline() {
  try {
    // Buscar food items do cache ou IndexedDB
    const cache = await caches.open(CACHE_NAME);
    const cachedResponse = await cache.match('/api/v1/food_items');
    
    if (!cachedResponse) {
      console.log('No cached food items found');
      return;
    }

    const foodItems = await cachedResponse.json();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Verificar quais itens estão perto de vencer
    const preferences = await getNotificationPreferences();
    const daysBeforeExpiration = preferences?.days_before_expiration || 7;

    for (const item of foodItems.food_items || foodItems) {
      if (!item.expiration_date) continue;

      const expirationDate = new Date(item.expiration_date);
      expirationDate.setHours(0, 0, 0, 0);
      
      const daysUntilExpiration = Math.floor((expirationDate - today) / (1000 * 60 * 60 * 24));

      // Verificar se deve notificar
      if (daysUntilExpiration <= daysBeforeExpiration && daysUntilExpiration >= 0) {
        await createOfflineNotification(item, daysUntilExpiration);
      }
    }
  } catch (error) {
    console.error('Error checking expirations offline:', error);
  }
}

async function createOfflineNotification(foodItem, daysRemaining) {
  // Evitar duplicatas verificando notificações recentes
  const recentNotifications = await getRecentNotifications(foodItem.id);
  if (recentNotifications.length > 0) {
    return;
  }

  let title, body, priority;

  if (daysRemaining === 0) {
    title = `🔴 ${foodItem.name} vence hoje!`;
    body = `Atenção! Este alimento vence hoje. Consuma o mais breve possível.`;
    priority = 2;
  } else if (daysRemaining === 1) {
    title = `🟠 ${foodItem.name} vence amanhã!`;
    body = `Atenção! Este alimento vence amanhã. Planeje consumi-lo em breve.`;
    priority = 2;
  } else if (daysRemaining <= 3) {
    title = `🟡 ${foodItem.name} vence em ${daysRemaining} dias`;
    body = `Este alimento vence em ${daysRemaining} dias.`;
    priority = 1;
  } else {
    title = `📅 ${foodItem.name} vence em ${daysRemaining} dias`;
    body = `Este alimento vence em ${daysRemaining} dias.`;
    priority = 0;
  }

  const notificationData = {
    title,
    body,
    icon: '/icon.png',
    badge: '/icon.png',
    tag: `expiration-${foodItem.id}`,
    requireInteraction: priority >= 2,
    data: {
      path: `/food_items/${foodItem.id}`,
      foodItemId: foodItem.id
    },
    timestamp: Date.now()
  };

  // Armazenar no IndexedDB
  await storeNotificationOffline(notificationData);

  // Exibir notificação
  await self.registration.showNotification(title, {
    body,
    icon: notificationData.icon,
    badge: notificationData.badge,
    tag: notificationData.tag,
    requireInteraction: notificationData.requireInteraction,
    data: notificationData.data
  });
}

async function markNotificationAsRead(notificationId) {
  try {
    await fetch(`/api/v1/notifications/${notificationId}/mark_as_read`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      }
    });
  } catch (error) {
    console.log('Could not mark notification as read (offline?)');
  }
}

// ==================== INDEXEDDB OPERATIONS ====================

function openNotificationsDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(NOTIFICATIONS_DB_NAME, 1);

    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);

    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      
      if (!db.objectStoreNames.contains(NOTIFICATIONS_STORE_NAME)) {
        const store = db.createObjectStore(NOTIFICATIONS_STORE_NAME, {
          keyPath: 'id',
          autoIncrement: true
        });
        store.createIndex('timestamp', 'timestamp', { unique: false });
        store.createIndex('foodItemId', 'data.foodItemId', { unique: false });
      }
    };
  });
}

async function storeNotificationOffline(notificationData) {
  try {
    const db = await openNotificationsDB();
    const transaction = db.transaction([NOTIFICATIONS_STORE_NAME], 'readwrite');
    const store = transaction.objectStore(NOTIFICATIONS_STORE_NAME);
    
    await store.add(notificationData);
  } catch (error) {
    console.error('Error storing notification offline:', error);
  }
}

async function getRecentNotifications(foodItemId) {
  try {
    const db = await openNotificationsDB();
    const transaction = db.transaction([NOTIFICATIONS_STORE_NAME], 'readonly');
    const store = transaction.objectStore(NOTIFICATIONS_STORE_NAME);
    const index = store.index('foodItemId');
    
    const notifications = [];
    const request = index.openCursor(IDBKeyRange.only(foodItemId));
    
    return new Promise((resolve, reject) => {
      request.onsuccess = (event) => {
        const cursor = event.target.result;
        if (cursor) {
          // Apenas notificações das últimas 24 horas
          const twentyFourHoursAgo = Date.now() - (24 * 60 * 60 * 1000);
          if (cursor.value.timestamp > twentyFourHoursAgo) {
            notifications.push(cursor.value);
          }
          cursor.continue();
        } else {
          resolve(notifications);
        }
      };
      request.onerror = () => reject(request.error);
    });
  } catch (error) {
    console.error('Error getting recent notifications:', error);
    return [];
  }
}

async function getNotificationPreferences() {
  try {
    const cache = await caches.open(CACHE_NAME);
    const cachedResponse = await cache.match('/api/v1/notification_preferences');
    
    if (cachedResponse) {
      return await cachedResponse.json();
    }
  } catch (error) {
    console.error('Error getting notification preferences:', error);
  }
  
  return { days_before_expiration: 7 };
}

// Placeholder functions - implementar com IndexedDB se necessário
async function getPendingSyncData() {
  return [];
}

async function removeSyncData(id) {
  return true;
}
