import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign Up (email + password + username)
  /// - username’i case-insensitive benzersiz kontrol eder (username_lc)
  /// - Auth kullanıcısını oluşturur
  /// - Firestore users/{uid} dokümanına email/username/username_lc yazar
  Future<User?> signUp(String email, String password, String username) async {
    final uname = username.trim();
    final unameLc = uname.toLowerCase();

    // 1) username unique kontrolü (case-insensitive)
    final taken = await _firestore
        .collection('users')
        .where('username_lc', isEqualTo: unameLc)
        .limit(1)
        .get();

    if (taken.docs.isNotEmpty) {
      throw Exception("Username is already taken");
    }

    // 2) Auth kaydı
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = cred.user;

    // 3) (opsiyonel) displayName
    await user?.updateDisplayName(uname);

    // 4) Firestore users/{uid}
    await _firestore.collection('users').doc(user!.uid).set({
      'email': email.trim(),
      'username': uname,        // orijinal yazım
      'username_lc': unameLc,   // normalize alan (lookup bununla yapılır)
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return user;
  }

  /// Sign In (email **veya** username ile)
  /// - '@' yoksa girilen şey username kabul edilir, email Firestore'dan bulunur
  Future<User?> signInWithEmailOrUsername(
    String emailOrUsername,
    String password,
  ) async {
    String email = emailOrUsername.trim();

    if (!email.contains('@')) {
      final unameLc = email.toLowerCase();

      // Önce username_lc üzerinden ara (case-insensitive)
      var snap = await _firestore
          .collection('users')
          .where('username_lc', isEqualTo: unameLc)
          .limit(1)
          .get();

      // Eski kayıtlar için fallback: username alanına göre ara (case-sensitive)
      if (snap.docs.isEmpty) {
        snap = await _firestore
            .collection('users')
            .where('username', isEqualTo: email)
            .limit(1)
            .get();
      }

      if (snap.docs.isEmpty) {
        throw Exception("No user found with that username");
      }

      email = (snap.docs.first.data()['email'] as String).trim();
    }

    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password.trim(),
    );
    return cred.user;
  }

  /// Logout
  Future<void> signOut() async => _auth.signOut();

  /// Current user
  User? get currentUser => _auth.currentUser;
}
