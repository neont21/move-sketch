import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/system/app_version_policy.dart';
import '../../../domain/models/enums/update_type.dart';
import '../../../utils/result.dart';

@immutable
final class AppVersionState {
  final AppVersionPolicy? policy;
  final UpdateType updateType;

  const AppVersionState({this.policy, this.updateType = UpdateType.none});

  bool get shouldUpdate => updateType != UpdateType.none && policy != null;

  bool get isForceUpdate => updateType == UpdateType.force;

  AppVersionState copyWith({AppVersionPolicy? policy, UpdateType? updateType}) {
    return AppVersionState(
      policy: policy ?? this.policy,
      updateType: updateType ?? this.updateType,
    );
  }
}

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

final appVersionViewModelProvider =
    AsyncNotifierProvider<AppVersionViewModel, AppVersionState>(() {
      return AppVersionViewModel();
    });
