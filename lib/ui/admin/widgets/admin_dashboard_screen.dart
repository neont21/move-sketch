import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../config/assets.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../view_models/admin_viewmodel.dart';
import 'notice_management_tab.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref.read(adminViewModelProvider.notifier).signOut();

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final String message = error is AppException
            ? error.message
            : '로그아웃 처리 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final AdminState adminState = ref
        .watch(adminViewModelProvider)
        .requireValue;
    final String adminEmail = adminState.email!;
    final bool isProcessing = adminState.isProcessing;

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = screenWidth < 680;
    final String displayEmail = isCompact && adminEmail.endsWith('@gmail.com')
        ? adminEmail.substring(0, adminEmail.indexOf('@gmail.com'))
        : adminEmail;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SvgPicture.asset(Assets.logoMark, width: 36, height: 36),
                      const SizedBox(width: 10),
                      Text('무브스케치 관리자 콘솔', style: textTheme.headlineSmall),
                      const Spacer(),
                      Tooltip(
                        message: adminEmail,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_circle_outlined,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayEmail,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: '로그아웃',
                        icon: const Icon(Icons.logout),
                        onPressed: isProcessing
                            ? null
                            : () => _handleSignOut(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.tertiaryContainer,
                    indicatorColor: colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: textTheme.bodyMedium,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.article_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('공지사항 관리'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('앱 버전 정책'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        NoticeManagementTab(),
                        Center(child: Text('버전 정책 관리 탭 (TODO)')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
