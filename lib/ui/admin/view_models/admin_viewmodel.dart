import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/social/social_auth_result.dart';
import '../../../domain/models/system/app_version_policy.dart';
import '../../../domain/models/system/notice.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

/// 웹 관리자 콘솔 접근이 허용된 관리자 이메일 화이트리스트.
const List<String> kAdminEmails = ['neont21@gmail.com'];

/// 관리자 인증 여부, 앱 버전 정책, 공지사항 목록 및 처리 상태를 보관하는 불변 상태 모델입니다.
@immutable
final class AdminState {
  /// 현재 로그인된 Google 계정의 이메일 주소.
  final String? email;

  /// 관리자 화이트리스트 검증 통과 여부.
  final bool isAdmin;

  /// 현재 원격 서버에 저장된 앱 버전 정책.
  final AppVersionPolicy? versionPolicy;

  /// 등록된 전체 공지사항 목록.
  final List<Notice> notices;

  /// 비동기 관리 작업(저장·등록·수정·삭제) 진행 중 여부.
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

/// 웹 관리자 콘솔의 Google 인증, 앱 버전 정책 관리 및 공지사항 CRUD를 담당하는 ViewModel입니다.
final class AdminViewModel extends AsyncNotifier<AdminState> {
  StreamSubscription<String?>? _authSubscription;

  // Firebase Auth 세션 변화를 감시해 로그아웃·계정 전환 시 관리자 상태를 갱신합니다.
  void _listenAuthState() {
    _authSubscription?.cancel();
    final authRepository = ref.read(authRepositoryProvider);

    _authSubscription = authRepository.authStateChanges.listen((uid) {
      if (!ref.mounted) {
        return;
      }

      if (uid == null) {
        state = const AsyncData(AdminState(isAdmin: false));
      } else {
        ref.invalidateSelf();
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

  /// 웹 관리자 콘솔에서 Google 계정으로 로그인하고 관리자 화이트리스트를 검증합니다.
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

              state = const AsyncData(
                AdminState(isAdmin: false, isProcessing: false),
              );

              return Result.error(AuthException('관리자 권한이 없는 계정입니다. ($email)'));
            }
          case SocialAuthNeedsOnboarding(:final email):
            if (email != null && kAdminEmails.contains(email)) {
              ref.invalidateSelf();

              return const Result.ok(null);
            } else {
              await authRepository.signOut();

              state = const AsyncData<AdminState>(
                AdminState(isAdmin: false, isProcessing: false),
              );

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

  /// 관리자 세션을 로그아웃하고 상태를 초기화합니다.
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

  /// 서버에서 최신 앱 버전 정책을 다시 조회해 상태를 갱신합니다.
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

  /// 서버에서 전체 공지사항 목록을 다시 조회해 상태를 갱신합니다.
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

  /// 수정된 앱 버전 정책([policy])을 원격 서버에 저장합니다.
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

  /// 신규 공지사항([notice])을 등록하고 목록을 새로고침합니다.
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

  /// 기존 공지사항([notice])을 수정하고 목록을 새로고침합니다.
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

  /// 지정된 공지사항([noticeId])을 삭제하고 목록을 새로고침합니다.
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

/// [AdminViewModel] 상태를 제공하는 전역 [AsyncNotifierProvider].
final adminViewModelProvider =
    AsyncNotifierProvider<AdminViewModel, AdminState>(() {
      return AdminViewModel();
    });
