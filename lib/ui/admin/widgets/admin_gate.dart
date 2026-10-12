import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/error_retry_view.dart';
import '../view_models/admin_viewmodel.dart';
import 'admin_dashboard_screen.dart';
import 'admin_login_view.dart';

class AdminGate extends ConsumerWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminViewModelProvider);

    return adminState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Scaffold(
        body: ErrorRetryView.fromError(
          error: error,
          defaultMessage: '관리자 정보를 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(adminViewModelProvider),
        ),
      ),
      data: (AdminState state) {
        if (!state.isAdmin) {
          return const AdminLoginView();
        }
        return const AdminDashboardScreen();
      },
    );
  }
}
