const CACHE_NAME = 'miminhos-cache-v1';
const urlsToCache = [
  './index.html',
  './manifest.json'
];

// Instalando Service Worker e cacheando arquivos
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

// Ativando SW
self.addEventListener('activate', event => {
  console.log('Service Worker ativado');
});

// Interceptando requests para servir do cache
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
