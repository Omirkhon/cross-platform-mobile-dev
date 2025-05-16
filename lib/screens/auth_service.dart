import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is guest
  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  // Stream of user state changes
  Stream<User?> get userState => _auth.authStateChanges();

  // Stream of tasks for the current user
  Stream<List<Map<String, dynamic>>> get tasksStream {
    if (isGuest) return const Stream.empty();
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

  // Sign in with email and password
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

  // Task operations
  Future<void> addTask(Map<String, dynamic> task) async {
    if (isGuest) return;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .add({
      ...task,
      'createdAt': FieldValue.serverTimestamp(),
    });
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