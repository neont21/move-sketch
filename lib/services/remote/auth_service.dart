import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<bool> isIdAvailable(String id) async {
    final doc = await _firestore.collection('account_ids').doc(id).get();
    return !doc.exists;
  }

  Future<UserCredential> signUpWithId({
    required String id,
    required String username,
    required String email,
    required String password,
  }) async {
    final isAvailable = await isIdAvailable(id);
    if (!isAvailable) {
      throw FirebaseAuthException(
        code: 'id-already-in-use',
        message: '이미 사용 중인 아이디입니다.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final batch = _firestore.batch();

    final accountIdRef = _firestore.collection('account_ids').doc(id);
    batch.set(accountIdRef, {
      'uid': uid,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final userRef = _firestore.collection('users').doc(uid);
    batch.set(userRef, {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'selectedCharacterId': 'bear',
    });

    await batch.commit();
    await credential.user!.sendEmailVerification();

    return credential;
  }

  Future<UserCredential> signInWithId({
    required String id,
    required String password,
  }) async {
    final doc = await _firestore.collection('account_ids').doc(id).get();

    if (!doc.exists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '존재하지 않는 아이디입니다.',
      );
    }

    final email = doc.data()?['email'] as String;
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }
    if (user.emailVerified) {
      throw StateError('이미 이메일 인증이 완료된 계정입니다.');
    }
    await user.sendEmailVerification();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({
    required String currentPassword,
    required String id,
  }) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(cred);

    await _firestore.collection('account_ids').doc(id).delete();
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
