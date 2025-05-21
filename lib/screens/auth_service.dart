import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
  Stream<User?> get userState => _auth.authStateChanges();

  final List<Map<String, dynamic>> _guestTasks = [];
  final StreamController<List<Map<String, dynamic>>> _guestTasksController = StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get tasksStream {
    if (isGuest) {
      return _guestTasksController.stream;
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((doc) => doc.data()..['id'] = doc.id)
          .toList());
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    if (isGuest) {
      final newTask = {
        ...task,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      _guestTasks.add(newTask);
      _guestTasksController.add(List.from(_guestTasks));
      return;
    }
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .add({
      ...task,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  @override
  void dispose() {
    _guestTasksController.close();
    super.dispose();
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'theme': 'system',
        'language': 'en',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    if (isGuest) return;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .update(updates);
  }

  Future<void> deleteTask(String taskId) async {
    if (isGuest) return;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Update user preferences
  Future<void> updateUserPreferences({
    String? theme,
    String? language,
  }) async {
    if (isGuest) return;

    Map<String, dynamic> updates = {};
    if (theme != null) updates['theme'] = theme;
    if (language != null) updates['language'] = language;

    await _firestore.collection('users').doc(currentUser!.uid).update(updates);
  }

  // Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    if (isGuest) return {};

    DocumentSnapshot snapshot = await _firestore.collection('users').doc(currentUser!.uid).get();
    return snapshot.data() as Map<String, dynamic>? ?? {};
  }
}