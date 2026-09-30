import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

class BlockedUsersViewModel extends AsyncNotifier<List<UserSummary>> {
  @override
  Future<List<UserSummary>> build() async {
    final currentUser = await ref.watch(authViewModelProvider.future);
    if (currentUser == null) {
      throw const AuthException('로그인된 사용자 세션이 없습니다.');
    }

    final friendshipRepository = ref.read(friendshipRepositoryProvider);
    final result = await friendshipRepository.getBlockedUsers(currentUser.uid);

    return switch (result) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };
  }
}

final blockedUsersViewModelProvider =
    AsyncNotifierProvider.autoDispose<BlockedUsersViewModel, List<UserSummary>>(
      () => BlockedUsersViewModel(),
    );
