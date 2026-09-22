import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:move_sketch/utils/exceptions.dart';
import '../../../config/dependencies.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/result.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  StreamSubscription<String?>? _authSubscription;

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
          Error() => const AsyncData(null),
        };
      }
    });
  }

  @override
  FutureOr<User?> build() async {
    _listenAuthState();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final uid = _authRepository.currentUid;
    if (uid == null) {
      return null;
    }

    final profileResult = await _userRepository.getCurrentUserProfile();
    return switch (profileResult) {
      Ok(:final value) => value,
      Error() => null,
    };
  }

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
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  Future<Result<User>> signUp({
    required String username,
    required String nickname,
    required String email,
    required String password,
    String selectedCharacterId = 'bear',
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
      selectedCharacterId: selectedCharacterId,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  Future<Result<bool>> isUsernameAvailable(String username) async {
    return _authRepository.isUsernameAvailable(username);
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return _authRepository.sendPasswordResetEmail(email);
  }

  Future<Result<User>> signInWithGoogle() async {
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
        state = AsyncData(value);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  Future<Result<User>> signInWithApple() async {
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
        state = AsyncData(value);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

  Future<Result<void>> signOut() async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final result = await _authRepository.signOut();

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok():
        state = const AsyncData(null);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }

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

  Future<Result<void>> deleteAccount({
    required String currentPassword,
    required String username,
  }) async {
    if (state.isLoading) {
      return const Result.error(ValidationException('이미 요청이 진행 중입니다.'));
    }

    state = const AsyncLoading();

    final result = await _authRepository.deleteAccount(
      currentPassword: currentPassword,
      username: username,
    );

    if (!ref.mounted) {
      return result;
    }

    switch (result) {
      case Ok():
        state = const AsyncData(null);
        return result;
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
        return result;
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).value;
});
