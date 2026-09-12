import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<PackageInfo> _getPackageInfo() => PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기본 설정', style: textTheme.labelLarge),
              ListTile(
                onTap: () {
                  context.go('/me/settings/account');
                },
                leading: Icon(
                  Icons.perm_identity,
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('계정 정보', style: textTheme.bodyLarge),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              ListTile(
                onTap: () {
                  context.go('/me/settings/character');
                },
                leading: Icon(Icons.pets, color: colorScheme.tertiaryContainer),
                title: Text('내 캐릭터', style: textTheme.bodyLarge),
                trailing: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '판다',
                      style: textTheme.bodyMedium?.copyWith(
                        color: textTheme.labelMedium?.color,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.tertiaryContainer,
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  context.go('/me/settings/notifications');
                },
                leading: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.tertiaryContainer,
                ),
                title: Text('푸시 알림', style: textTheme.bodyLarge),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              Divider(color: Colors.transparent),
              Text('앱 정보', style: textTheme.labelLarge),
              ListTile(
                onTap: () {
                  context.push('/privacy');
                },
                title: Text('개인정보처리방침', style: textTheme.bodyMedium),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              ListTile(
                onTap: () {
                  context.push('/tos');
                },
                title: Text('이용약관', style: textTheme.bodyMedium),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              ListTile(
                onTap: () {
                  context.push('/license');
                },
                title: Text('오픈소스 라이선스', style: textTheme.bodyMedium),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
              Divider(color: Colors.transparent),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<PackageInfo>(
                    future: _getPackageInfo(),
                    builder: (context, snapshot) {
                      final PackageInfo info;
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Container();
                      }
                      info = snapshot.data!;
                      return Text(
                        'v${info.version}',
                        style: textTheme.labelSmall,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
