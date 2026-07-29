importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBRQlYTa8qsq45P3oRsAc3id5ruDM2H4g4",
  appId: "1:190632344732:web:f5f2c0fc4f84c634b70159",
  messagingSenderId: "190632344732",
  projectId: "verifiedmaids",
  authDomain: "verifiedmaids.firebaseapp.com",
  storageBucket: "verifiedmaids.firebasestorage.app",
  measurementId: "G-1FZD5VX478"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title || 'Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/favicon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
