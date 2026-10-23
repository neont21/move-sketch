import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/system/app_version_policy.dart';
import '../../../domain/models/system/notice.dart';
import '../../../domain/models/social/social_auth_result.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

const List<String> kAdminEmails = ['neont21@gmail.com'];

@immutable
class AdminState {
  final String? email;
  final bool isAdmin;
  final AppVersionPolicy? versionPolicy;
  final List<Notice> notices;
  final bool isProcessing;

  const AdminState({
    this.email,
    this.isAdmin = false,
    this.versionPolicy,
    this.notices = const [],
    this.isProcessing = false,
  });

  AdminState copyWith({
    String? email,
    bool? isAdmin,
    AppVersionPolicy? versionPolicy,
    List<Notice>? notices,
    bool? isProcessing,
  }) {
    return AdminState(
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      versionPolicy: versionPolicy ?? this.versionPolicy,
      notices: notices ?? this.notices,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class AdminViewModel extends AsyncNotifier<AdminState> {
  StreamSubscription<String?>? _authSubscription;

  void _listenAuthState() {
    _authSubscription?.cancel();
    final authRepository = ref.read(authRepositoryProvider);

    _authSubscription = authRepository.authStateChanges.listen((uid) {
      if (!ref.mounted) {
        return;
      }

      if (uid == null) {
        state = const AsyncData(AdminState(isAdmin: false));
      }
    });
  }

  @override
  Future<AdminState> build() async {
    if (!kIsWeb) {
      return const AdminState();
    }

    _listenAuthState();
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final authRepository = ref.watch(authRepositoryProvider);
    final googleEmail = authRepository.providerEmails['google.com'];

    final isAdministrator =
        googleEmail != null && kAdminEmails.contains(googleEmail);

    if (!isAdministrator) {
      return AdminState(email: googleEmail, isAdmin: false);
    }

    final versionRepository = ref.read(appVersionRepositoryProvider);
    final noticeRepository = ref.read(noticeRepositoryProvider);

    final (versionResult, noticeResult) = await (
      versionRepository.getVersionPolicy(),
      noticeRepository.getAllNotices(),
    ).wait;

    final versionPolicy = switch (versionResult) {
      Ok(:final value) => value,
      Error() => null,
    };
    final notices = switch (noticeResult) {
      Ok(:final value) => value,
      Error() => const <Notice>[],
    };

    return AdminState(
      email: googleEmail,
      isAdmin: true,
      versionPolicy: versionPolicy,
      notices: notices,
    );
  }

  Future<Result<void>> signInWithGoogle() async {
    if (!kIsWeb) {
      return const Result.error(AuthException('관리자 기능은 웹 환경에서만 지원됩니다.'));
    }

    final current = state.value ?? const AdminState();
    state = AsyncData(current.copyWith(isProcessing: true));

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signInWithGoogle();

    switch (result) {
      case Ok(:final value):
        switch (value) {
          case SocialAuthSuccess(:final user):
            final email = user.email;
            if (email != null && kAdminEmails.contains(email)) {
              ref.invalidateSelf();

              return const Result.ok(null);
            } else {
              await authRepository.signOut();

              state = const AsyncData(AdminState(isAdmin: false, isProcessing: false));

              return Result.error(AuthException('관리자 권한이 없는 계정입니다. ($email)'));
            }
          case SocialAuthNeedsOnboarding(:final email):
            if (email != null && kAdminEmails.contains(email)) {
              ref.invalidateSelf();

              return const Result.ok(null);
            } else {
              await authRepository.signOut();

              state = const AsyncData<AdminState>(AdminState(isAdmin: false, isProcessing: false));

              return Result.error(AuthException('관리자 권한이 없는 계정입니다. ($email)'));
            }
          case SocialAuthCanceled():
            state = AsyncData(current.copyWith(isProcessing: false));

            return const Result.error(AuthException('로그인이 취소되었습니다'));
        }
      case Error(:final error):
        ref.invalidateSelf();

        return Result.error(error);
    }
  }

  Future<Result<void>> signOut() async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signOut();

    switch (result) {
      case Ok():
        state = const AsyncData(AdminState());

        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));
        return Result.error(error);
    }
  }

  Future<Result<void>> refreshVersionPolicy() async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final versionRepository = ref.read(appVersionRepositoryProvider);
    final result = await versionRepository.getVersionPolicy();

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          current.copyWith(versionPolicy: value, isProcessing: false),
        );

        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));

        return Result.error(error);
    }
  }

  Future<Result<void>> refreshNotices() async {
    final current = state.value;
    if (current == null) {
      return const Result.ok(null);
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final noticeRepository = ref.read(noticeRepositoryProvider);
    final result = await noticeRepository.getAllNotices();

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          current.copyWith(notices: value, isProcessing: false),
        );

        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));

        return Result.error(error);
    }
  }

  Future<Result<void>> saveVersionPolicy(AppVersionPolicy policy) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(AuthException('관리자 세션이 유효하지 않습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final versionRepository = ref.read(appVersionRepositoryProvider);
    final result = await versionRepository.updateVersionPolicy(policy);

    switch (result) {
      case Ok():
        state = AsyncData(
          current.copyWith(versionPolicy: policy, isProcessing: false),
        );

        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));

        return Result.error(error);
    }
  }

  Future<Result<void>> createNotice(Notice notice) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(AuthException('관리자 세션이 유효하지 않습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final noticeRepository = ref.read(noticeRepositoryProvider);
    final result = await noticeRepository.createNotice(notice);

    switch (result) {
      case Ok():
        await refreshNotices();

        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));

        return Result.error(error);
    }
  }

  Future<Result<void>> updateNotice(Notice notice) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(AuthException('관리자 세션이 유효하지 않습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final noticeRepository = ref.read(noticeRepositoryProvider);
    final result = await noticeRepository.updateNotice(notice);

    switch (result) {
      case Ok():
        await refreshNotices();

        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));

        return Result.error(error);
    }
  }

  Future<Result<void>> deleteNotice(String noticeId) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(AuthException('관리자 세션이 유효하지 않습니다.'));
    }

    state = AsyncData(current.copyWith(isProcessing: true));

    final noticeRepository = ref.read(noticeRepositoryProvider);
    final result = await noticeRepository.deleteNotice(noticeId);

    switch (result) {
      case Ok():
        await refreshNotices();
        return const Result.ok(null);
      case Error(:final error):
        state = AsyncData(current.copyWith(isProcessing: false));

        return Result.error(error);
    }
  }
}

final adminViewModelProvider = AsyncNotifierProvider<AdminViewModel, AdminState>(() {
  return AdminViewModel();
});
