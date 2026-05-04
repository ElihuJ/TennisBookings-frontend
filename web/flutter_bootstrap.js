{{flutter_js}}
{{flutter_build_config}}

// Hard-refresh helper called by Dart when a new app version is detected.
// A plain location.reload() is not enough — the service worker intercepts
// every request and serves stale cached files. This function:
//   1. Deletes every cache the service worker created
//   2. Unregisters all service workers so nothing intercepts the reload
//   3. Reloads — the browser now fetches every asset fresh from the server
window._forceUpdate = async function () {
  try {
    if ('caches' in window) {
      const keys = await caches.keys();
      await Promise.all(keys.map(function (k) { return caches.delete(k); }));
    }
    if ('serviceWorker' in navigator) {
      const regs = await navigator.serviceWorker.getRegistrations();
      await Promise.all(regs.map(function (r) { return r.unregister(); }));
    }
  } finally {
    window.location.reload();
  }
};

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    let appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    const loading = document.getElementById('flutter-loading');
    if (loading) {
      loading.classList.add('fade-out');
      setTimeout(() => loading.remove(), 500);
    }
  }
});
