// Инициализация Firebase
const admin = require('firebase-admin');
const serviceAccount = require('./beauty-salon-app-6f1d1-firebase-adminsdk-fbsvc-6f2d205f00.json'); // Файл с ключами сервисного аккаунта

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const firestore = admin.firestore();

// Данные о мастерах
const mastersData = [
  {
    userId: 'master1', // ID связанного пользователя
    displayName: 'Анна Петрова',
    specializations: ['Парикмахер', 'Колорист', 'Стилист'],
    experience: '5 лет',
    description: {
      'ru': 'Анна специализируется на женских стрижках и окрашивании. Постоянно следит за трендами и регулярно проходит курсы повышения квалификации.',
      'kk': 'Анна әйелдер шаш қию және бояу бойынша маманданған. Үнемі трендтерді қадағалап, жүйелі түрде біліктілікті арттыру курстарынан өтеді.',
      'en': 'Anna specializes in women\'s haircuts and coloring. She constantly monitors trends and regularly takes advanced training courses.'
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/masters%2Fanna.jpg?alt=media',
    portfolio: [
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fanna1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fanna2.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fanna3.jpg?alt=media'
    ],
    schedule: {
      'monday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'tuesday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'wednesday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'thursday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'friday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'saturday': {
        'start': '10:00',
        'end': '16:00',
        'breaks': []
      },
      'sunday': null
    },
    rating: 4.8,
    reviewsCount: 124
  },
  {
    userId: 'master2',
    displayName: 'Алексей Иванов',
    specializations: ['Барбер', 'Стилист мужских причесок'],
    experience: '3 года',
    description: {
      'ru': 'Алексей - профессиональный барбер с опытом работы в лучших барбершопах Астаны. Специализируется на классических и модных мужских стрижках, моделировании бороды.',
      'kk': 'Алексей - Астананың үздік барбершоптарында жұмыс тәжірибесі бар кәсіби барбер. Классикалық және сәнді ерлер шаш қию, сақал үлгілеу бойынша маманданған.',
      'en': 'Alexey is a professional barber with experience in the best barbershops in Astana. Specializes in classic and fashionable men\'s haircuts, beard modeling.'
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/masters%2Falexey.jpg?alt=media',
    portfolio: [
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Falexey1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Falexey2.jpg?alt=media'
    ],
    schedule: {
      'monday': null,
      'tuesday': {
        'start': '10:00',
        'end': '20:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'wednesday': {
        'start': '10:00',
        'end': '20:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'thursday': {
        'start': '10:00',
        'end': '20:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'friday': {
        'start': '10:00',
        'end': '20:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'saturday': {
        'start': '11:00',
        'end': '18:00',
        'breaks': []
      },
      'sunday': {
        'start': '11:00',
        'end': '16:00',
        'breaks': []
      }
    },
    rating: 4.6,
    reviewsCount: 85
  },
  {
    userId: 'master3',
    displayName: 'Мария Кузнецова',
    specializations: ['Мастер ногтевого сервиса', 'Мастер педикюра'],
    experience: '7 лет',
    description: {
      'ru': 'Мария - высококвалифицированный мастер маникюра и педикюра. Владеет самыми современными техниками нейл-арта и уходовыми процедурами.',
      'kk': 'Мария - жоғары білікті маникюр және педикюр шебері. Ең заманауи нейл-арт техникаларын және күтім процедураларын меңгерген.',
      'en': 'Maria is a highly qualified master of manicure and pedicure. She owns the most modern techniques of nail art and care procedures.'
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/masters%2Fmaria.jpg?alt=media',
    portfolio: [
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fmaria1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fmaria2.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fmaria3.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fmaria4.jpg?alt=media'
    ],
    schedule: {
      'monday': {
        'start': '10:00',
        'end': '19:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'tuesday': {
        'start': '10:00',
        'end': '19:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'wednesday': {
        'start': '10:00',
        'end': '19:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'thursday': null,
      'friday': {
        'start': '10:00',
        'end': '19:00',
        'breaks': [
          {
            'start': '14:00',
            'end': '15:00'
          }
        ]
      },
      'saturday': {
        'start': '10:00',
        'end': '17:00',
        'breaks': []
      },
      'sunday': null
    },
    rating: 4.9,
    reviewsCount: 203
  },
  {
    userId: 'master4',
    displayName: 'Айнура Сатпаева',
    specializations: ['Визажист', 'Мастер по бровям', 'Лешмейкер'],
    experience: '4 года',
    description: {
      'ru': 'Айнура - талантливый визажист и мастер по оформлению бровей. Создает уникальные образы, подчеркивающие индивидуальность клиентов.',
      'kk': 'Айнура - талантты визажист және қас қою шебері. Клиенттердің жеке басын көрсететін бірегей образдар жасайды.',
      'en': 'Ainura is a talented makeup artist and eyebrow master. Creates unique images that emphasize the individuality of clients.'
    },
    photoURL: 'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/masters%2Fainura.jpg?alt=media',
    portfolio: [
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fainura1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fainura2.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/beauty-salon-app-6f1d1.firebasestorage.app/o/portfolio%2Fainura3.jpg?alt=media'
    ],
    schedule: {
      'monday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'tuesday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'wednesday': null,
      'thursday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'friday': {
        'start': '09:00',
        'end': '18:00',
        'breaks': [
          {
            'start': '13:00',
            'end': '14:00'
          }
        ]
      },
      'saturday': {
        'start': '10:00',
        'end': '16:00',
        'breaks': []
      },
      'sunday': null
    },
    rating: 4.7,
    reviewsCount: 95
  }
];

// Функция для добавления данных о мастерах в Firestore
async function addMastersData() {
  const batch = firestore.batch();
  
  mastersData.forEach((master, index) => {
    const docRef = firestore.collection('masters').doc(`master${index + 1}`);
    batch.set(docRef, master);
  });
  
  await batch.commit();
  console.log('Мастера успешно добавлены в базу данных');
}

// Функция для создания связей между мастерами и услугами
async function linkMastersToServices() {
  // Получаем существующие услуги
  const servicesSnapshot = await firestore.collection('services').get();
  
  // Услуги по категориям
  const servicesByCategory = {
    'hair': [], // Парикмахерские услуги
    'nails': [], // Ногтевой сервис
    'makeup': [], // Макияж и брови
    'barbershop': [] // Услуги барбершопа
  };
  
  // Распределяем услуги по категориям
  servicesSnapshot.forEach(doc => {
    const serviceData = doc.data();
    if (serviceData.category === '2') { // ID категории "Парикмахерские услуги"
      servicesByCategory.hair.push(doc.id);
    } else if (serviceData.category === '3') { // ID категории "Ногтевой сервис"
      servicesByCategory.nails.push(doc.id);
    } else if (serviceData.category === '4') { // ID категории "Макияж"
      servicesByCategory.makeup.push(doc.id);
    }
  });
  
  // Связываем мастеров с услугами
  const batch = firestore.batch();
  
  // Анна Петрова - парикмахер
  servicesByCategory.hair.forEach(serviceId => {
    const serviceRef = firestore.collection('services').doc(serviceId);
    batch.update(serviceRef, {
      'availableMasters.master1': true
    });
  });
  
  // Алексей Иванов - барбер
  servicesByCategory.barbershop.forEach(serviceId => {
    const serviceRef = firestore.collection('services').doc(serviceId);
    batch.update(serviceRef, {
      'availableMasters.master2': true
    });
  });
  
  // Мария Кузнецова - мастер ногтевого сервиса
  servicesByCategory.nails.forEach(serviceId => {
    const serviceRef = firestore.collection('services').doc(serviceId);
    batch.update(serviceRef, {
      'availableMasters.master3': true
    });
  });
  
  // Айнура Сатпаева - визажист и мастер по бровям
  servicesByCategory.makeup.forEach(serviceId => {
    const serviceRef = firestore.collection('services').doc(serviceId);
    batch.update(serviceRef, {
      'availableMasters.master4': true
    });
  });
  
  await batch.commit();
  console.log('Связи между мастерами и услугами успешно созданы');
}

// Запускаем функции добавления данных
async function initializeData() {
  try {
    await addMastersData();
    await linkMastersToServices();
    console.log('Инициализация данных завершена успешно');
  } catch (error) {
    console.error('Ошибка при инициализации данных:', error);
  } finally {
    admin.app().delete(); // Закрываем соединение с Firebase
  }
}

initializeData();