import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/enums/update_type.dart';
import '../../../domain/models/system/app_version_policy.dart';
import '../../../utils/result.dart';

/// 원격 앱 버전 정책과 현재 빌드의 업데이트 필요 여부를 보관하는 불변 상태 모델입니다.
@immutable
final class AppVersionState {
  /// 서버에서 조회한 최신 앱 버전 정책.
  final AppVersionPolicy? policy;

  /// 현재 빌드 번호 기준으로 판별된 업데이트 유형.
  final UpdateType updateType;

  const AppVersionState({this.policy, this.updateType = UpdateType.none});

  /// 업데이트 안내 다이얼로그를 표시해야 하는지 여부.
  bool get shouldUpdate => updateType != UpdateType.none && policy != null;

  /// 앱 사용을 차단하는 강제 업데이트가 필요한지 여부.
  bool get isForceUpdate => updateType == UpdateType.force;

  AppVersionState copyWith({AppVersionPolicy? policy, UpdateType? updateType}) {
    return AppVersionState(
      policy: policy ?? this.policy,
      updateType: updateType ?? this.updateType,
    );
  }
}

/// 앱 실행 시 원격 버전 정책([AppVersionPolicy])을 조회해 업데이트 유형을 판별하는 ViewModel입니다.
final class AppVersionViewModel extends AsyncNotifier<AppVersionState> {
  @override
  Future<AppVersionState> build() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

    final appVersionRepository = ref.read(appVersionRepositoryProvider);
    final result = await appVersionRepository.getVersionPolicy();

    return switch (result) {
      Ok(:final value) => AppVersionState(
        policy: value,
        updateType: value.checkUpdateType(currentBuildNumber),
      ),
      Error() => const AppVersionState(),
    };
  }
}

/// [AppVersionViewModel] 상태를 제공하는 전역 [AsyncNotifierProvider].
final appVersionViewModelProvider =
    AsyncNotifierProvider<AppVersionViewModel, AppVersionState>(() {
      return AppVersionViewModel();
    });
