// firebase-scripts/initialize-loyalty.js

const admin = require('firebase-admin');
const serviceAccount = require('./beauty-salon-app-6f1d1-firebase-adminsdk-fbsvc-c49cfda238.json');

// Инициализация Firebase
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const firestore = admin.firestore();

// Данные акций для программы лояльности
const promotionsData = [
  {
    title: {
      'ru': 'Скидка 10% на любую услугу',
      'kk': 'Кез келген қызметке 10% жеңілдік',
      'en': '10% discount on any service',
    },
    description: {
      'ru': 'Получите скидку 10% на любую услугу в нашем салоне. Скидка применяется один раз для одной услуги.',
      'kk': 'Біздің салонда кез келген қызметке 10% жеңілдік алыңыз. Жеңілдік бір қызмет үшін бір рет қолданылады.',
      'en': 'Get a 10% discount on any service in our salon. The discount is applied once for one service.',
    },
    points: 200,
    isActive: true,
    // Срок действия - 3 месяца от текущей даты
    endDate: Date.now() + 7889400000, // Примерно 3 месяца в миллисекундах
  },
  {
    title: {
      'ru': 'Бесплатный массаж головы',
      'kk': 'Тегін бас массажы',
      'en': 'Free head massage',
    },
    description: {
      'ru': 'Получите бесплатный массаж головы при следующем посещении. Можно использовать вместе с любой услугой.',
      'kk': 'Келесі сапарыңызда тегін бас массажын алыңыз. Кез келген қызметпен бірге пайдалануға болады.',
      'en': 'Get a free head massage on your next visit. Can be used with any service.',
    },
    points: 300,
    isActive: true,
    // Срок действия - 2 месяца от текущей даты
    endDate: Date.now() + 5259600000, // Примерно 2 месяца в миллисекундах
  },
  {
    title: {
      'ru': 'Скидка 15% на окрашивание',
      'kk': 'Бояуға 15% жеңілдік',
      'en': '15% discount on coloring',
    },
    description: {
      'ru': 'Получите скидку 15% на любую услугу окрашивания волос. Не суммируется с другими скидками.',
      'kk': 'Кез келген шаш бояу қызметіне 15% жеңілдік алыңыз. Басқа жеңілдіктермен біріктірілмейді.',
      'en': 'Get a 15% discount on any hair coloring service. Cannot be combined with other discounts.',
    },
    points: 350,
    isActive: true,
    // Срок действия - 3 месяца от текущей даты
    endDate: Date.now() + 7889400000, // Примерно 3 месяца в миллисекундах
  },
  {
    title: {
      'ru': 'Бесплатная укладка',
      'kk': 'Тегін шаш сәндеу',
      'en': 'Free styling',
    },
    description: {
      'ru': 'Получите бесплатную укладку волос при следующем посещении. Не суммируется с другими акциями.',
      'kk': 'Келесі сапарыңызда тегін шаш сәндеуге ие болыңыз. Басқа акциялармен біріктірілмейді.',
      'en': 'Get a free hair styling on your next visit. Cannot be combined with other promotions.',
    },
    points: 500,
    isActive: true,
    // Срок действия - 2 месяца от текущей даты
    endDate: Date.now() + 5259600000, // Примерно 2 месяца в миллисекундах
  },
  {
    title: {
      'ru': 'VIP-обслуживание на день',
      'kk': 'Бір күнге VIP қызмет',
      'en': 'VIP service for a day',
    },
    description: {
      'ru': 'Получите VIP-обслуживание на один день, включая приоритетную запись, персонального ассистента и комплимент от салона.',
      'kk': 'Бір күнге VIP қызмет алыңыз, оның ішінде басым жазба, жеке көмекші және салоннан сыйлық бар.',
      'en': 'Get VIP service for one day, including priority booking, personal assistant and a compliment from the salon.',
    },
    points: 1000,
    isActive: true,
    // Срок действия - 6 месяцев от текущей даты
    endDate: Date.now() + 15778800000, // Примерно 6 месяцев в миллисекундах
  },
];

// Функция для инициализации программы лояльности
async function initializeLoyalty() {
  try {
    // Создание акций программы лояльности
    const batch = firestore.batch();
    
    // Проверяем существование коллекции promotions
    const promotionsSnapshot = await firestore.collection('promotions').limit(1).get();
    
    // Если коллекция пуста, добавляем акции
    if (promotionsSnapshot.empty) {
      console.log('Добавление акций программы лояльности...');
      
      for (const promotion of promotionsData) {
        const docRef = firestore.collection('promotions').doc();
        batch.set(docRef, promotion);
      }
      
      await batch.commit();
      console.log('Акции программы лояльности успешно добавлены');
    } else {
      console.log('Акции программы лояльности уже существуют');
    }
    
    console.log('Инициализация программы лояльности завершена');
  } catch (error) {
    console.error('Ошибка при инициализации программы лояльности:', error);
  } finally {
    // Закрываем соединение с Firebase
    if (admin.apps.length) {
      await admin.app().delete();
    }
  }
}

// Запускаем функцию инициализации
initializeLoyalty();