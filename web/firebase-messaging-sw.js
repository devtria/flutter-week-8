importScripts(
  "https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js",
);

firebase.initializeApp({
  apiKey: "AIzaSyDVzoUPCprplkxMYiYsCEcVYodf6OS2DaY",
  authDomain: "devbase-project-2f49c.firebaseapp.com",
  projectId: "devbase-project-2f49c",
  storageBucket: "devbase-project-2f49c.firebasestorage.app",
  messagingSenderId: "799431251950",
  appId: ":728405486252:web:41d090ceecfc96ce3e8d09r",
});

const messaging = firebase.messaging();
