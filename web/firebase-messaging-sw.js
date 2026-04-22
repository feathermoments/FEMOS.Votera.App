importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

// Firebase config must be duplicated here for the service worker.
const firebaseConfig = {
  apiKey: "AIzaSyC1HLkWJh7bZYk6GU_RgqCwfbldlnS9IOg",
  authDomain: "votera-6ffda.firebaseapp.com",
  projectId: "votera-6ffda",
  storageBucket: "votera-6ffda.firebasestorage.app",
  messagingSenderId: "105535083242",
  appId: "1:105535083242:web:00000000000000"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = payload.notification?.title ?? 'Votera';
  const notificationOptions = {
    body: payload.notification?.body ?? '',
    icon: '/favicon.png'
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
