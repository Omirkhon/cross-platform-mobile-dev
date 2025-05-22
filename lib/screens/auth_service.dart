import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'connectivity_service.dart';

class AuthService with ChangeNotifier {
  bool _shouldShowSyncButton = false;
  bool get shouldShowSyncButton => _shouldShowSyncButton;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<dynamic> _localStorage = Hive.box('localStorage');
  final Box<dynamic> _prefsBox = Hive.box('preferences');

  User? get currentUser => _auth.currentUser;
  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
  Stream<User?> get userState => _auth.authStateChanges();
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool _hasPendingSync = false;
  bool get hasPendingSync => _hasPendingSync;

  final List<Map<String, dynamic>> _guestTasks = [];
  final StreamController<List<Map<String, dynamic>>> _guestTasksController =
  StreamController<List<Map<String, dynamic>>>.broadcast();

  late BuildContext _context;

  AuthService(BuildContext context) {
    _context = context;
    _initLocalStorage();
    _initConnectivity();
  }

  void _initConnectivity() {
    // Get initial connectivity state
    Connectivity().checkConnectivity().then((result) {
      _handleConnectivityChange(result);
    });

    // Listen for changes
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _initLocalStorage() async {
    await _prefsBox.put('theme', 'system');
    await _prefsBox.put('language', 'en');
  }

  Future<bool> _isOffline() async {
    final connectivity = Provider.of<ConnectivityService>(_context, listen: false);
    return connectivity.isOffline;
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _handleConnectivityChange(connectivityResult);
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(ConnectivityResult result) async {
    final offline = result == ConnectivityResult.none;
    if (offline) {
      _shouldShowSyncButton = false;
      notifyListeners();
      return;
    }

    // When coming back online, check for pending sync
    final localTasks = _localStorage.get('tasks', defaultValue: []);
    if (localTasks.isNotEmpty) {
      _hasPendingSync = true;
      _shouldShowSyncButton = true; // Show the sync button
      notifyListeners();
    }
  }

  Stream<List<Map<String, dynamic>>> get tasksStream async* {
    if (isGuest) {
      yield* _guestTasksController.stream;
      return;
    }

    // Check if we have cached data
    final cachedTasks = _localStorage.get('tasks', defaultValue: []);
    if (cachedTasks is List && cachedTasks.isNotEmpty) {
      yield cachedTasks.cast<Map<String, dynamic>>();
      await syncData();
    }

    yield* _firestore
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
    final newTask = {
      ...task,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (isGuest) {
      _guestTasks.add(newTask);
      _guestTasksController.add(List.from(_guestTasks));
      return;
    }

    // Add to local storage first
    final localTasks = List<Map<String, dynamic>>.from(
        _localStorage.get('tasks', defaultValue: []));
    localTasks.add(newTask);
    await _localStorage.put('tasks', localTasks);

    // Try to sync if online
    await syncData();
  }

  Future<void> syncData() async {
    if (isGuest || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final localTasks = List<Map<String, dynamic>>.from(
          _localStorage.get('tasks', defaultValue: []));

      if (localTasks.isNotEmpty) {
        final batch = _firestore.batch();
        final tasksRef = _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('tasks');

        for (final task in localTasks) {
          final taskData = {...task};
          final id = taskData.remove('id');
          batch.set(tasksRef.doc(id), taskData);
        }

        await batch.commit();
        await _localStorage.put('tasks', []);
        _hasPendingSync = false;
        _shouldShowSyncButton = false; // Hide the sync button after successful sync
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync error: $e');
      // Keep the sync button visible if sync fails
      _shouldShowSyncButton = true;
      notifyListeners();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
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

  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    if (isGuest) return;

    // Update local storage first
    final localTasks = List<Map<String, dynamic>>.from(
        _localStorage.get('tasks', defaultValue: []));
    final taskIndex = localTasks.indexWhere((t) => t['id'] == taskId);

    if (taskIndex != -1) {
      localTasks[taskIndex] = {...localTasks[taskIndex], ...updates};
      await _localStorage.put('tasks', localTasks);
    }

    // Try to sync with Firebase
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .update(updates);
    } catch (e) {
      debugPrint('Failed to update task: $e');
    }
  }

  // Future<void> deleteTask(String taskId) async {
  //   if (isGuest) return;

  //   // Remove from local storage first
  //   final localTasks = List<Map<String, dynamic>>.from(
  //       _localStorage.get('tasks', defaultValue: []));
  //   localTasks.removeWhere((t) => t['id'] == taskId);
  //   await _localStorage.put('tasks', localTasks);

  //   // Try to sync with Firebase
  //   try {
  //     await _firestore
  //         .collection('users')
  //         .doc(currentUser!.uid)
  //         .collection('tasks')
  //         .doc(taskId)
  //         .delete();
  //   } catch (e) {
  //     debugPrint('Failed to delete task: $e');
  //   }
  // }

  Future<void> deleteTask(String taskId) async {
    if (isGuest) return;
    final localTasks = List<Map<String, dynamic>>.from(
        _localStorage.get('tasks', defaultValue: []));
    final index = localTasks.indexWhere((t) => t['id'] == taskId);

    if (index != -1) {
      localTasks[index]['deleted'] = true;
      await _localStorage.put('tasks', localTasks);
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .update({'deleted': true});
    } catch (e) {
      debugPrint('Failed to mark task as deleted: $e');
    }
  }


  Future<void> updateUserPreferences({
    String? theme,
    String? language,
  }) async {
    if (isGuest) return;

    // Update local storage immediately
    if (theme != null) await _prefsBox.put('theme', theme);
    if (language != null) await _prefsBox.put('language', language);

    // Try to sync with Firebase
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        if (theme != null) 'theme': theme,
        if (language != null) 'language': language,
      });
    } catch (e) {
      debugPrint('Failed to sync preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    if (isGuest) return {};

    // First try to get from local storage
    final localPrefs = {
      'theme': _prefsBox.get('theme', defaultValue: 'system'),
      'language': _prefsBox.get('language', defaultValue: 'en'),
    };

    // Then try to sync with Firebase
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      final firebasePrefs = snapshot.data() as Map<String, dynamic>? ?? {};

      // Merge preferences (Firebase overrides local)
      return {...localPrefs, ...firebasePrefs};
    } catch (e) {
      return localPrefs;
    }
  }
}