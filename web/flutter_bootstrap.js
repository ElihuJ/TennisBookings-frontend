{{flutter_js}}
{{flutter_build_config}}

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
