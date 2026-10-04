const CACHE = "stimmig-v1";
const ASSETS = [
  "./", "index.html", "manifest.webmanifest",
  "icons/icon-192.png", "icons/icon-512.png", "icons/maskable-512.png",
  "fonts/bricolage-500.ttf", "fonts/bricolage-700.ttf", "fonts/bricolage-800.ttf",
  "fonts/inter-400.ttf", "fonts/inter-500.ttf", "fonts/inter-600.ttf",
  "datenschutz.html", "impressum.html", "support.html"
];
self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys()
    .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  if (e.request.method !== "GET") return;
  e.respondWith(caches.match(e.request).then(hit => hit || fetch(e.request)));
});
