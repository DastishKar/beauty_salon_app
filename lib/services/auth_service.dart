// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUserModel;
  
  // Получение текущего пользователя Firebase
  User? get currentUser => _auth.currentUser;
  
  // Получение текущей модели пользователя
  UserModel? get currentUserModel => _currentUserModel;
  
  // Статус аутентификации
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Слушатель изменений состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Проверка, является ли пользователь администратором
  bool get isAdmin => _currentUserModel?.role == 'admin';
  
  // Инициализация при старте приложения
  Future<void> initialize() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          await _fetchUserModel(user.uid);
        } catch (e) {
          if (kDebugMode) {
            print('Ошибка при получении данных пользователя: $e');
          }
        }
      } else {
        _currentUserModel = null;
      }
      notifyListeners();
    });
  }
  
  // Регистрация по email и паролю
  Future<UserCredential> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    String phoneNumber,
    String language,
  ) async {
    try {
      // Создание пользователя в Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Установка отображаемого имени
      await userCredential.user?.updateDisplayName(name);
      
      // Создание модели пользователя
      final UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        displayName: name,
        email: email,
        phoneNumber: phoneNumber,
        role: 'client',
        language: language,
        createdAt: DateTime.now(),
      );
      
      // Сохранение данных пользователя в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());
      
      _currentUserModel = userModel;
      notifyListeners();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Обработка специфических ошибок Firebase
      if (e.code == 'weak-password') {
        throw 'Слишком слабый пароль';
      } else if (e.code == 'email-already-in-use') {
        throw 'Этот email уже используется другим аккаунтом';
      } else {
        throw 'Ошибка регистрации: ${e.message}';
      }
    } catch (e) {
      throw 'Произошла ошибка при регистрации: $e';
    }
  }
  
  // Вход по email и паролю
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _fetchUserModel(userCredential.user!.uid);
      notifyListeners();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Пользователь с таким email не найден';
      } else if (e.code == 'wrong-password') {
        throw 'Неверный пароль';
      } else {
        throw 'Ошибка входа: ${e.message}';
      }
    } catch (e) {
      throw 'Произошла ошибка при входе: $e';
    }
  }
  
  // Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserModel = null;
    notifyListeners();
  }
  
  // Восстановление пароля
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Ошибка при отправке письма для восстановления пароля: $e';
    }
  }
  
  // Обновление данных пользователя
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? language,
    String? photoBase64, // Changed from photoURL
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final Map<String, dynamic> updateData = {};
      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (language != null) updateData['language'] = language;
      if (photoBase64 != null) updateData['photoBase64'] = photoBase64;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      // Refresh user data
      await _fetchUserModel(user.uid);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
  
  // Получение данных пользователя из Firestore
  Future<void> _fetchUserModel(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        _currentUserModel = UserModel.fromMap(userId, doc.data() as Map<String, dynamic>);
      } else {
        // Если пользователь есть в Auth, но нет в Firestore, создаем запись
        final User user = _auth.currentUser!;
        final UserModel newUser = UserModel(
          id: user.uid,
          displayName: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          photoBase64: user.photoURL,
          role: 'client',
          language: 'ru',
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _currentUserModel = newUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении данных пользователя: $e');
      }
      throw 'Не удалось получить данные пользователя';
    }
  }
  
  // Повышение роли пользователя до администратора
  Future<bool> promoteToAdmin(String userId) async {
    if (!isAdmin) {
      throw 'Недостаточно прав для выполнения этой операции';
    }
    
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin'
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при повышении роли пользователя: $e');
      }
      return false;
    }
  }
  
  // Понижение роли администратора до клиента
  Future<bool> demoteToClient(String userId) async {
    if (!isAdmin) {
      throw 'Недостаточно прав для выполнения этой операции';
    }
    
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'client'
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при понижении роли пользователя: $e');
      }
      return false;
    }
  }
}