import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase Authentication 기반의 이메일·소셜 인증, 계정 연동 및 재인증을 처리하는 서비스 클래스입니다.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// 현재 Firebase Auth에 로그인된 사용자 객체.
  User? get currentUser => _auth.currentUser;

  /// 현재 로그인된 사용자의 고유 식별자.
  String? get currentUid => _auth.currentUser?.uid;

  /// 인증 상태 변경(로그인, 로그아웃, 토큰 갱신)을 방출하는 스트림.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 현재 로그인된 사용자의 이메일 인증 완료 여부.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// 현재 계정에 연동된 인증 제공자 ID 목록.
  List<String> get linkedProviders {
    return _auth.currentUser?.providerData
            .map((userInfo) => userInfo.providerId)
            .toList() ??
        const [];
  }

  /// 연동된 인증 제공자 ID별 등록 이메일 주소 맵.
  Map<String, String> get providerEmails {
    final user = _auth.currentUser;
    if (user == null) return const {};
    return {
      for (final info in user.providerData)
        if (info.email != null && info.email!.isNotEmpty)
          info.providerId: info.email!,
    };
  }

  /// 이메일([email])과 비밀번호([password])로 신규 Firebase 계정을 생성합니다.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 이메일([email])과 비밀번호([password])로 로그인합니다.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Google OAuth 인증을 통해 로그인하며, 사용자가 취소한 경우 `null`을 반환합니다.
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      return await _auth.signInWithPopup(GoogleAuthProvider());
    }

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

  // Apple Sign-In의 Replay Attack 방지를 위해 암호학적으로 안전한 무작위 Nonce 문자열을 생성합니다.
  String _generateNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Apple OAuth 인증(Android 웹 플로우 및 iOS/macOS 네이티브 Nonce 검증 포함)으로 로그인합니다.
  Future<UserCredential?> signInWithApple() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AppleAuthProvider appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      return await _auth.signInWithProvider(appleProvider);
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

  /// 현재 로그인된 계정에 Google 인증 제공자를 추가로 연동합니다.
  Future<UserCredential?> linkGoogle() async {
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

      return await user.linkWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  /// 현재 로그인된 계정에 Apple 인증 제공자를 추가로 연동합니다.
  Future<UserCredential?> linkApple() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AppleAuthProvider appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      return await user.linkWithProvider(appleProvider);
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

    return await user.linkWithCredential(credential);
  }

  /// 현재 로그인된 계정에 이메일·비밀번호 로그인 수단을 추가로 연동합니다.
  Future<void> linkEmailAndPassword({
    required String email,
    required String password,
  }) async {
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

  /// 지정된 인증 제공자([providerId]) 연동을 해제하며, 유효한 로그인 수단이 모두 사라지는 경우 예외를 던집니다.
  Future<void> unlinkProvider(String providerId) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    final Iterable<UserInfo> remainingValidProviders = user.providerData.where((
      UserInfo providerInfo,
    ) {
      if (providerInfo.providerId == providerId) {
        return false;
      }
      if (providerInfo.providerId == 'password') {
        return user.emailVerified;
      }
      return true;
    });

    if (remainingValidProviders.isEmpty) {
      throw FirebaseAuthException(
        code: 'cannot-unlink-last-provider',
        message: '유효한 로그인 수단이 최소 하나는 유지되어야 하므로 연결을 해제할 수 없습니다.',
      );
    }

    await user.unlink(providerId);
  }

  /// 현재 로그인된 사용자 세션을 로그아웃합니다.
  Future<void> signOut() => _auth.signOut();

  /// 지정된 이메일([email])로 비밀번호 재설정 안내 메일을 발송합니다.
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// 현재 로그인된 미인증 계정으로 이메일 인증 메일을 재발송합니다.
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

  /// 서버에서 사용자 정보를 새로고침([User.reload])한 뒤 최신 이메일 인증 여부를 반환합니다.
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// 현재 비밀번호([currentPassword])로 재인증한 뒤 새 비밀번호([newPassword])로 변경합니다.
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

  /// 민감한 계정 작업 전 현재 비밀번호([currentPassword])로 재인증을 수행합니다.
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

  /// Google 계정을 통해 재인증을 수행하며, 사용자가 취소한 경우 `null`을 반환합니다.
  Future<UserCredential?> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
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

      return await user.reauthenticateWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  /// Apple 계정을 통해 재인증을 수행합니다.
  Future<UserCredential?> reauthenticateWithApple() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인된 사용자가 없습니다.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AppleAuthProvider appleAuthProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      return await user.reauthenticateWithProvider(appleAuthProvider);
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

    return await user.reauthenticateWithCredential(credential);
  }

  /// 현재 로그인된 Firebase Auth 계정을 영구 삭제합니다.
  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }
}
