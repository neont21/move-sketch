import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/social/social_auth_result.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/view_models/push_notification_viewmodel.dart';

/// 앱 전역의 사용자 인증 상태([User?])를 관리하고 로그인·회원가입·소셜 온보딩·로그아웃·탈퇴를 조율하는 ViewModel입니다.
final class AuthViewModel extends AsyncNotifier<User?> {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  StreamSubscription<String?>? _authSubscription;

  /// 현재 계정에 연결된 인증 공급자 식별자 목록.
  List<String> get linkedProviders => _authRepository.linkedProviders;

  // 네이티브 모바일 환경에서 푸시 알림 초기화 및 Crashlytics 사용자 식별자를 연동합니다.
  void _setupNativeUserServices(String userId) {
    if (!kIsWeb) {
      ref.read(pushNotificationViewModelProvider.notifier).initialize(userId);
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  // 로그아웃 또는 계정 탈퇴 시 Crashlytics 사용자 식별자를 초기화합니다.
  void _clearNativeUserIdentifier() {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.setUserIdentifier('');
    }
  }

  // Firebase Auth 상태 스트림을 구독해 외부 세션 만료·전환 시 프로필 상태를 동기화합니다.
  void _listenAuthState() {
    _authSubscription?.cancel();

    _authSubscription = _authRepository.authStateChanges.listen((uid) async {
      if (state.isLoading) {
        return;
      }

      if (uid == null) {
        if (!ref.mounted) {
          return;
        }

        state = const AsyncData(null);
      } else if (state.value?.uid != uid) {
        final profileResult = await _userRepository.getCurrentUserProfile();
        if (!ref.mounted) {
          return;
        }

        state = switch (profileResult) {
          Ok(:final value) => AsyncData(value),
          Error(:final error) => AsyncError(error, StackTrace.current),
        };

        if (state.value != null) {
          _setupNativeUserServices(uid);
        }
      }
    });
  }

  @override
  FutureOr<User?> build() async {
    _listenAuthState();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    String? uid = _authRepository.currentUid;
    if (uid == null && kIsWeb) {
      try {
        uid = await _authRepository.authStateChanges.first;
      } catch (_) {
        uid = null;
      }
    }

    if (uid == null) {
      return null;
    }

    final profileResult = await _userRepository.getCurrentUserProfile();
    final user = switch (profileResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    if (user != null) {
      _setupNativeUserServices(user.uid);
    }

    return user;
  }

  /// 서버에서 현재 사용자의 최신 프로필을 다시 조회해 상태를 갱신합니다.
  Future<Result<User>> refreshCurrentUser() async {
    final profileResult = await _userRepository.getCurrentUserProfile();
    switch (profileResult) {
      case Ok(:final value):
        if (value == null) {
          return const Result.error(NotFoundException('사용자 정보를 찾을 수 없습니다.'));
        }
        if (ref.mounted) {
          state = AsyncData(value);
        }
        return Result.ok(value);
      case Error(:final error):
        return Result.error(error);
    }
  }

  /// 아이디 또는 이메일([username])과 비밀번호([password])로 로그인을 수행합니다.
  Future<Result<User>> signIn({
    required String username,
    required String password,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }
    state = const AsyncLoading();

    final result = await _authRepository.signInWithUsername(
      username: username,
      password: password,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        _setupNativeUserServices(value.uid);

        return result;
      case Error():
        state = AsyncData(null);
        return result;
    }
  }

  /// 아이디([username]), 닉네임([nickname]), 이메일([email]), 비밀번호([password]) 및 초기 캐릭터([character])로 회원가입을 수행합니다.
  Future<Result<User>> signUp({
    required String username,
    required String nickname,
    required String email,
    required String password,
    CharacterType character = CharacterType.bear,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final result = await _authRepository.signUpWithUsername(
      username: username,
      nickname: nickname,
      email: email,
      password: password,
      selectedCharacter: character,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        _setupNativeUserServices(value.uid);

        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  /// 입력한 아이디([username])의 사용 가능 여부를 확인합니다.
  Future<Result<bool>> isUsernameAvailable(String username) async {
    return _authRepository.isUsernameAvailable(username);
  }

  /// 지정된 이메일([email])로 비밀번호 재설정 안내 메일을 발송합니다.
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return _authRepository.sendPasswordResetEmail(email);
  }

  /// Google 계정으로 로그인하거나 신규 소셜 온보딩 분기 결과를 반환합니다.
  Future<Result<SocialAuthResult>> signInWithGoogle() async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final result = await _authRepository.signInWithGoogle();

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(:final value):
        switch (value) {
          case SocialAuthSuccess(:final user):
            state = AsyncData(user);
            _setupNativeUserServices(user.uid);
          case SocialAuthNeedsOnboarding():
            state = const AsyncData(null);
          case SocialAuthCanceled():
            state = const AsyncData(null);
        }
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  /// Apple 계정으로 로그인하거나 신규 소셜 온보딩 분기 결과를 반환합니다.
  Future<Result<SocialAuthResult>> signInWithApple() async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final result = await _authRepository.signInWithApple();

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(:final value):
        switch (value) {
          case SocialAuthSuccess(:final user):
            state = AsyncData(user);
            _setupNativeUserServices(user.uid);
          case SocialAuthNeedsOnboarding():
            state = const AsyncData(null);
          case SocialAuthCanceled():
            state = const AsyncData(null);
        }
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  /// 소셜 로그인 신규 사용자의 프로필을 등록하고 가입 절차를 완료합니다.
  Future<Result<User>> completeSocialSignUp({
    required String username,
    required String nickname,
    required CharacterType selectedCharacter,
    File? imageFile,
    String? profileImageUrl,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final result = await _authRepository.completeSocialSignUp(
      username: username,
      nickname: nickname,
      imageFile: imageFile,
      profileImageUrl: profileImageUrl,
      selectedCharacter: selectedCharacter,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        _setupNativeUserServices(value.uid);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  /// FCM 토큰을 무효화한 뒤 현재 사용자 계정을 로그아웃합니다.
  Future<Result<void>> signOut() async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final currentUid = state.value?.uid ?? _authRepository.currentUid;
    if (currentUid != null) {
      await ref
          .read(pushNotificationViewModelProvider.notifier)
          .clearPushToken(currentUid);
    }

    final result = await _authRepository.signOut();

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok():
        _clearNativeUserIdentifier();
        state = const AsyncData(null);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  /// 현재 비밀번호([currentPassword])를 검증한 뒤 새 비밀번호([newPassword])로 변경합니다.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    return _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// 비밀번호 재인증 후 FCM 토큰과 계정 데이터를 영구 삭제합니다.
  Future<Result<void>> deleteAccountWithPassword({
    required String currentPassword,
    required String username,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final currentUid = state.value?.uid ?? _authRepository.currentUid;
    if (currentUid != null) {
      await ref
          .read(pushNotificationViewModelProvider.notifier)
          .clearPushToken(currentUid);
    }

    final result = await _authRepository.deleteAccountWithPassword(
      currentPassword: currentPassword,
      username: username,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok():
        _clearNativeUserIdentifier();
        state = const AsyncData(null);
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
    }

    return result;
  }

  /// Google 재인증 후 FCM 토큰과 계정 데이터를 영구 삭제합니다.
  Future<Result<bool>> deleteAccountWithGoogle({
    required String username,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final currentUid = state.value?.uid ?? _authRepository.currentUid;
    if (currentUid != null) {
      await ref
          .read(pushNotificationViewModelProvider.notifier)
          .clearPushToken(currentUid);
    }

    final result = await _authRepository.deleteAccountWithGoogle(
      username: username,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(value: true):
        _clearNativeUserIdentifier();
        state = const AsyncData(null);
      case Ok(value: false):
        state = AsyncData(ref.read(currentUserProvider));
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
    }
    return result;
  }

  /// Apple 재인증 후 FCM 토큰과 계정 데이터를 영구 삭제합니다.
  Future<Result<bool>> deleteAccountWithApple({
    required String username,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final currentUid = state.value?.uid ?? _authRepository.currentUid;
    if (currentUid != null) {
      await ref
          .read(pushNotificationViewModelProvider.notifier)
          .clearPushToken(currentUid);
    }

    final result = await _authRepository.deleteAccountWithApple(
      username: username,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(value: true):
        _clearNativeUserIdentifier();
        state = const AsyncData(null);
      case Ok(value: false):
        state = AsyncData(ref.read(currentUserProvider));
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
    }
    return result;
  }
}

/// [AuthViewModel] 상태를 제공하는 전역 [AsyncNotifierProvider].
final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, User?>(() {
  return AuthViewModel();
});

/// 현재 로그인된 [User] 객체를 구독하는 편의 [Provider].
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authViewModelProvider).value;
});
