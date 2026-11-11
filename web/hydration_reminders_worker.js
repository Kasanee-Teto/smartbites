self.addEventListener('notificationclick', (event) => {
  if (event.notification.tag !== 'smartbites-hydration') return;
  event.notification.close();
  const page = event.notification.data.page;
  const minutes = Number(event.action);
  event.waitUntil((async () => {
    const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    const client = windows.find((window) => window.url === page);
    if (client) {
      if ([5, 15, 30].includes(minutes)) {
        client.postMessage({ type: 'smartbites-hydration', minutes });
      } else {
        await client.focus();
      }
    } else if (!event.action) {
      await self.clients.openWindow(page);
    }
  })());
});
