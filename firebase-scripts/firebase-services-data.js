// Инициализация Firebase
const admin = require('firebase-admin');
const serviceAccount = require('./beauty-salon-app-6f1d1-firebase-adminsdk-fbsvc-6f2d205f00.json'); // Файл с ключами сервисного аккаунта

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const firestore = admin.firestore();

// Данные категорий
const categoriesData = [
  {
    name: {
      'ru': 'Все услуги',
      'kk': 'Барлық қызметтер',
      'en': 'All services',
    },
    description: {
      'ru': 'Все услуги нашего салона',
      'kk': 'Біздің салонның барлық қызметтері',
      'en': 'All services of our salon',
    },
    photoURL: null,
    order: 0,
  },
  {
    name: {
      'ru': 'Парикмахерские услуги',
      'kk': 'Шаштараз қызметтері',
      'en': 'Hair services',
    },
    description: {
      'ru': 'Стрижки, окрашивание и укладка',
      'kk': 'Шаш қию, бояу және сәндеу',
      'en': 'Haircuts, coloring and styling',
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/categories%2Fhair.jpg?alt=media',
    order: 1,
  },
  {
    name: {
      'ru': 'Ногтевой сервис',
      'kk': 'Тырнақ қызметі',
      'en': 'Nail services',
    },
    description: {
      'ru': 'Маникюр, педикюр, наращивание',
      'kk': 'Маникюр, педикюр, ұзарту',
      'en': 'Manicure, pedicure, extensions',
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/categories%2Fnail.jpg?alt=media',
    order: 2,
  },
  {
    name: {
      'ru': 'Макияж',
      'kk': 'Макияж',
      'en': 'Makeup',
    },
    description: {
      'ru': 'Профессиональный макияж, оформление бровей',
      'kk': 'Кәсіби макияж, қасты құрастыру',
      'en': 'Professional makeup, eyebrow shaping',
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/categories%2Fmakeup.jpg?alt=media',
    order: 3,
  },
  {
    name: {
      'ru': 'Барбершоп',
      'kk': 'Барбершоп',
      'en': 'Barbershop',
    },
    description: {
      'ru': 'Мужские стрижки, бритье, моделирование бороды',
      'kk': 'Ерлер шаш қию, қырыну, сақал үлгілеу',
      'en': 'Men\'s haircuts, shaving, beard styling',
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/categories%2Fbarbershop.jpg?alt=media',
    order: 4,
  },
];

// Данные услуг
const servicesData = [
  // Парикмахерские услуги
  {
    name: {
      'ru': 'Женская стрижка',
      'kk': 'Әйелдер шаш қию',
      'en': 'Women\'s haircut',
    },
    description: {
      'ru': 'Профессиональная женская стрижка от наших стилистов. Включает мытье головы, стрижку и укладку.',
      'kk': 'Біздің стилистерден кәсіби әйелдер шаш қию. Бас жуу, шаш қию және сәндеуді қамтиды.',
      'en': 'Professional women\'s haircut from our stylists. Includes hair washing, cutting and styling.',
    },
    category: '2', // ID категории "Парикмахерские услуги"
    duration: 60, // в минутах
    price: 5000, // в тенге
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fwomens-haircut.jpg?alt=media',
    availableMasters: {}, // Будет заполнено скриптом связи мастеров и услуг
    isActive: true,
  },
  {
    name: {
      'ru': 'Окрашивание волос',
      'kk': 'Шаш бояу',
      'en': 'Hair coloring',
    },
    description: {
      'ru': 'Окрашивание волос профессиональными красителями. Подбор оттенка с учетом цветотипа внешности.',
      'kk': 'Кәсіби бояғыштармен шаш бояу. Сыртқы келбетінің түстік түріне сәйкес реңкті таңдау.',
      'en': 'Hair coloring with professional dyes. Selection of shade taking into account the color type of appearance.',
    },
    category: '2',
    duration: 120,
    price: 12000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fhair-coloring.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Укладка волос',
      'kk': 'Шаш сәндеу',
      'en': 'Hair styling',
    },
    description: {
      'ru': 'Профессиональная укладка волос. Подбор стиля с учетом формы лица и структуры волос.',
      'kk': 'Кәсіби шаш сәндеу. Бет пішіні мен шаш құрылымына сәйкес стильді таңдау.',
      'en': 'Professional hair styling. Selection of style taking into account the shape of the face and hair structure.',
    },
    category: '2',
    duration: 45,
    price: 4000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fhair-styling.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  
  // Ногтевой сервис
  {
    name: {
      'ru': 'Маникюр классический',
      'kk': 'Классикалық маникюр',
      'en': 'Classic manicure',
    },
    description: {
      'ru': 'Классический маникюр включает обработку кутикулы, придание формы ногтям и покрытие лаком.',
      'kk': 'Классикалық маникюр кутикулды өңдеуді, тырнақтарға пішін беруді және лакпен жабуды қамтиды.',
      'en': 'Classic manicure includes cuticle treatment, nail shaping and varnish coating.',
    },
    category: '3', // ID категории "Ногтевой сервис"
    duration: 60,
    price: 4000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fclassic-manicure.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Маникюр с гель-лаком',
      'kk': 'Гель-лакпен маникюр',
      'en': 'Gel polish manicure',
    },
    description: {
      'ru': 'Маникюр с покрытием гель-лаком. Держится до 2-3 недель без сколов и потери блеска.',
      'kk': 'Гель-лак жабындысы бар маникюр. Шытынаусыз және жылтырды жоғалтпай 2-3 аптаға дейін сақталады.',
      'en': 'Manicure with gel polish coating. Lasts up to 2-3 weeks without chipping and loss of shine.',
    },
    category: '3',
    duration: 90,
    price: 6000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fgel-manicure.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Педикюр',
      'kk': 'Педикюр',
      'en': 'Pedicure',
    },
    description: {
      'ru': 'Комплексный уход за ногтями и кожей ног. Включает обработку пяток, придание формы ногтям и покрытие лаком.',
      'kk': 'Тырнақтар мен аяқ терісіне кешенді күтім. Өкшелерді өңдеуді, тырнақтарға пішін беруді және лак жабуды қамтиды.',
      'en': 'Comprehensive care for toenails and foot skin. Includes heel treatment, nail shaping and varnish coating.',
    },
    category: '3',
    duration: 90,
    price: 7000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fpedicure.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  
  // Макияж
  {
    name: {
      'ru': 'Дневной макияж',
      'kk': 'Күндізгі макияж',
      'en': 'Day makeup',
    },
    description: {
      'ru': 'Легкий макияж для повседневного образа. Идеально подходит для работы, учебы и прогулок.',
      'kk': 'Күнделікті бейнеге арналған жеңіл макияж. Жұмыс, оқу және серуендеу үшін тамаша.',
      'en': 'Light makeup for everyday look. Perfect for work, study and walks.',
    },
    category: '4', // ID категории "Макияж"
    duration: 45,
    price: 5000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fday-makeup.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Вечерний макияж',
      'kk': 'Кешкі макияж',
      'en': 'Evening makeup',
    },
    description: {
      'ru': 'Яркий макияж для особых случаев. Подчеркнет вашу красоту на вечеринке, свидании или торжественном мероприятии.',
      'kk': 'Ерекше жағдайларға арналған жарқын макияж. Кештерде, кездесулерде немесе салтанатты шараларда сұлулығыңызды көрсетеді.',
      'en': 'Bright makeup for special occasions. Will highlight your beauty at a party, date or solemn event.',
    },
    category: '4',
    duration: 60,
    price: 7000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fevening-makeup.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Коррекция и окрашивание бровей',
      'kk': 'Қастарды түзету және бояу',
      'en': 'Eyebrow correction and coloring',
    },
    description: {
      'ru': 'Профессиональная коррекция формы бровей и окрашивание хной или краской для бровей.',
      'kk': 'Қастардың пішінін кәсіби түзету және хна немесе қас бояғышымен бояу.',
      'en': 'Professional correction of eyebrow shape and coloring with henna or eyebrow paint.',
    },
    category: '4',
    duration: 45,
    price: 4000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Feyebrow-correction.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  
  // Барбершоп
  {
    name: {
      'ru': 'Мужская стрижка',
      'kk': 'Ерлер шаш қию',
      'en': 'Men\'s haircut',
    },
    description: {
      'ru': 'Профессиональная мужская стрижка от наших барберов. Включает мытье головы и укладку.',
      'kk': 'Біздің барберлерден кәсіби ерлер шаш қию. Бас жуу және сәндеуді қамтиды.',
      'en': 'Professional men\'s haircut from our barbers. Includes hair washing and styling.',
    },
    category: '5', // ID категории "Барбершоп"
    duration: 30,
    price: 3000,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fmens-haircut.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Бритье опасной бритвой',
      'kk': 'Қауіпті ұстарамен қырыну',
      'en': 'Straight razor shaving',
    },
    description: {
      'ru': 'Классическое бритье опасной бритвой. Включает распаривание кожи, нанесение специальных средств и массаж лица.',
      'kk': 'Қауіпті ұстарамен классикалық қырыну. Теріні булауды, арнайы құралдарды жағуды және бет массажын қамтиды.',
      'en': 'Classic straight razor shaving. Includes steaming the skin, applying special products and facial massage.',
    },
    category: '5',
    duration: 45,
    price: 3500,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fstraight-razor.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  },
  {
    name: {
      'ru': 'Моделирование бороды',
      'kk': 'Сақал үлгілеу',
      'en': 'Beard styling',
    },
    description: {
      'ru': 'Профессиональное моделирование бороды. Мастер подберет форму бороды, учитывая особенности вашего лица.',
      'kk': 'Сақалды кәсіби үлгілеу. Шебер бетіңіздің ерекшеліктерін ескере отырып, сақал пішінін таңдайды.',
      'en': 'Professional beard styling. The master will select the shape of the beard, taking into account the features of your face.',
    },
    category: '5',
    duration: 30,
    price: 2500,
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/services%2Fbeard-styling.jpg?alt=media',
    availableMasters: {},
    isActive: true,
  }
];

// Функция для добавления категорий в Firestore
async function addCategories() {
  const batch = firestore.batch();
  
  categoriesData.forEach((category, index) => {
    const docRef = firestore.collection('categories').doc(`${index + 1}`);
    batch.set(docRef, category);
  });
  
  await batch.commit();
  console.log('Категории успешно добавлены в базу данных');
}

// Функция для добавления услуг в Firestore
async function addServices() {
  const batch = firestore.batch();
  
  servicesData.forEach((service, index) => {
    const docRef = firestore.collection('services').doc(`${index + 1}`);
    batch.set(docRef, service);
  });
  
  await batch.commit();
  console.log('Услуги успешно добавлены в базу данных');
}

// Запускаем функции добавления данных
async function initializeData() {
  try {
    await addCategories();
    await addServices();
    console.log('Инициализация данных завершена успешно');
  } catch (error) {
    console.error('Ошибка при инициализации данных:', error);
  } finally {
    admin.app().delete(); // Закрываем соединение с Firebase
  }
}

initializeData();