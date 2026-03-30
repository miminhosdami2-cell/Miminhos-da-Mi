const CACHE_NAME = 'miminhos-cache-v2'; // Mudei para v2 para o telemóvel atualizar
const urlsToCache = [
  './',
  './index.html',
  './manifest.json',
  'https://fonts.googleapis.com/css2?family=Great+Vibes&display=swap'
];

// Instalação e Cache Inicial
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(urlsToCache);
    })
  );
  self.skipWaiting();
});

// Limpeza de Caches Antigos
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.filter(name => name !== CACHE_NAME).map(name => caches.delete(name))
      );
    })
  );
});

// Estratégia: Cache First para Imagens, Network First para API
self.addEventListener('fetch', event => {
  const url = event.request.url;

  // Se for uma IMAGEM, tenta carregar do Cache primeiro (Cache First)
  if (event.request.destination === 'image' || url.includes('.jpg') || url.includes('.png')) {
    event.respondWith(
      caches.match(event.request).then(response => {
        return response || fetch(event.request).then(fetchRes => {
          return caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, fetchRes.clone());
            return fetchRes;
          });
        });
      })
    );
  } 
  // Se for a API do Google Sheets, tenta Internet primeiro, mas guarda cópia se falhar (Network First)
  else if (url.includes('script.google.com')) {
    event.respondWith(
      fetch(event.request).then(fetchRes => {
        return caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, fetchRes.clone());
          return fetchRes;
        });
      }).catch(() => caches.match(event.request))
    );
  }
  // Para o resto (HTML, CSS), usa o padrão
  else {
    event.respondWith(
      caches.match(event.request).then(response => response || fetch(event.request))
    );
  }
});
