import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  List<String> get linkedProviders {
    return _auth.currentUser?.providerData
            .map((userInfo) => userInfo.providerId)
            .toList() ??
        const [];
  }

  Map<String, String> get providerEmails {
    final user = _auth.currentUser;
    if (user == null) return const {};
    return {
      for (final info in user.providerData)
        if (info.email != null && info.email!.isNotEmpty)
          info.providerId: info.email!,
    };
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final GoogleSignInAuthentication googleAuth = account.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<UserCredential?> signInWithApple() async {
    final String rawNonce = _generateNonce();
    final String sha256Nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: sha256Nonce,
        );

    final OAuthCredential credential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );

    if (appleCredential.givenName != null ||
        appleCredential.familyName != null) {
      final String displayName = [
        appleCredential.familyName,
        appleCredential.givenName,
      ].where((name) => name != null && name.isNotEmpty).join();
      if (displayName.isNotEmpty && userCredential.user?.displayName == null) {
        await userCredential.user?.updateDisplayName(displayName);
      }
    }
    return userCredential;
  }

  Future<void> linkGoogle() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final GoogleSignInAuthentication googleAuth = account.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      rethrow;
    }
  }

  Future<void> linkApple() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    final String rawNonce = _generateNonce();
    final String sha256Nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID appleCredential =
    await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256Nonce,
    );

    final OAuthCredential credential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    await user.linkWithCredential(credential);
  }

  Future<void> linkEmailAndPassword({
    required String email,
    required String password,
})async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    final AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.linkWithCredential(credential);
}

  Future<void> unlinkProvider(String providerId) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    if (user.providerData.length <= 1) {
      throw FirebaseAuthException(
        code: 'cannot-unlink-last-provider',
        message: '유일한 로그인 수단은 연결 해제할 수 없습니다.',
      );
    }

    await user.unlink(providerId);
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
      throw FirebaseAuthException(
        code: 'already-verified',
        message: '이미 이메일 인증이 완료된 계정입니다.',
      );
    }
    await user.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
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

  Future<void> reauthenticate({required String currentPassword}) async {
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
  }

  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }
}
