(() => {
  const supported = window.isSecureContext &&
    'Notification' in window && 'serviceWorker' in navigator;
  const tag = 'smartbites-hydration';
  const snoozeMinutes = [5, 15, 30];
  let worker;
  let audio;
  let notificationVersion = 0;

  function registration() {
    worker ??= navigator.serviceWorker.register(new URL('hydration_reminders_worker.js', document.baseURI), {
      scope: new URL('hydration-notifications/', document.baseURI).href,
    }).then((registration) => {
      if (registration.active) return registration;
      const installing = registration.installing || registration.waiting;
      if (!installing) return null;
      return new Promise((resolve) => {
        const check = () => {
          if (installing.state === 'activated' || installing.state === 'redundant') {
            installing.removeEventListener('statechange', check);
            resolve(installing.state === 'activated' ? registration : null);
          }
        };
        installing.addEventListener('statechange', check);
        check();
      });
    }).catch(() => null);
    return worker;
  }

  window.smartBitesHydration = {
    supported,
    async requestPermission() {
      if (!supported) return 'unsupported';
      try {
        const permission = Notification.permission === 'default'
          ? await Notification.requestPermission()
          : Notification.permission;
        if (permission === 'granted' && !await registration()) return 'unsupported';
        return permission;
      } catch (_) {
        return 'unsupported';
      }
    },
    prepareSound() {
      const Audio = window.AudioContext || window.webkitAudioContext;
      if (!Audio) return;
      audio ??= new Audio();
      audio.resume().catch(() => {});
    },
    playSound(alarm) {
      if (!audio || audio.state !== 'running') return;
      const start = audio.currentTime;
      const notes = alarm ? [660, 880, 660, 880] : [523, 659];
      notes.forEach((frequency, index) => {
        const time = start + index * 0.23;
        const oscillator = audio.createOscillator();
        const gain = audio.createGain();
        oscillator.frequency.value = frequency;
        gain.gain.setValueAtTime(0.11, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 0.2);
        oscillator.connect(gain).connect(audio.destination);
        oscillator.start(time);
        oscillator.stop(time + 0.21);
      });
    },
    async notify() {
      if (!supported || Notification.permission !== 'granted') return;
      const version = ++notificationVersion;
      try {
        const serviceWorker = await registration();
        if (!serviceWorker || version !== notificationVersion) return;
        await serviceWorker.showNotification('Pengingat minum', {
          body: 'Sudah waktunya mencatat minuman di SmartBites.',
          tag,
          icon: new URL('icons/Icon-192.png', document.baseURI).href,
          data: { page: location.href },
          actions: snoozeMinutes.map((minutes) => ({
            action: String(minutes), title: `Tunda ${minutes} mnt`,
          })),
        });
      } catch (_) {
        // The in-app reminder stays available if the browser refuses delivery.
      }
    },
    async clear() {
      const version = ++notificationVersion;
      try {
        const serviceWorker = await worker;
        const notifications = await serviceWorker?.getNotifications({ tag });
        if (version === notificationVersion) {
          notifications?.forEach((notification) => notification.close());
        }
      } catch (_) {
        // The browser may revoke notification access during a session.
      }
    },
    listen(onSnooze) {
      if (!supported) return () => {};
      const handle = ({ data }) => {
        if (data?.type === tag && snoozeMinutes.includes(data.minutes)) {
          onSnooze(data.minutes);
        }
      };
      navigator.serviceWorker.addEventListener('message', handle);
      return () => navigator.serviceWorker.removeEventListener('message', handle);
    },
  };
})();
