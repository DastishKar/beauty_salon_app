// Сохраните этот код как check-database.js в директории firebase-scripts
const admin = require('firebase-admin');
const serviceAccount = require('./beauty-salon-app-6f1d1-firebase-adminsdk-fbsvc-00c32b0798.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const firestore = admin.firestore();

async function checkDatabase() {
  try {
    // Проверка наличия мастеров
    const mastersSnapshot = await firestore.collection('masters').get();
    console.log(`Количество мастеров: ${mastersSnapshot.size}`);
    if (mastersSnapshot.size > 0) {
      console.log('Пример мастера:', mastersSnapshot.docs[0].data());
    }

    // Проверка наличия услуг
    const servicesSnapshot = await firestore.collection('services').get();
    console.log(`Количество услуг: ${servicesSnapshot.size}`);
    if (servicesSnapshot.size > 0) {
      console.log('Пример услуги:', servicesSnapshot.docs[0].data());
    }

    // Проверка наличия категорий
    const categoriesSnapshot = await firestore.collection('categories').get();
    console.log(`Количество категорий: ${categoriesSnapshot.size}`);
    if (categoriesSnapshot.size > 0) {
      console.log('Пример категории:', categoriesSnapshot.docs[0].data());
    }
  } catch (error) {
    console.error('Ошибка при проверке базы данных:', error);
  } finally {
    admin.app().delete(); // Завершаем соединение
  }
}

checkDatabase();