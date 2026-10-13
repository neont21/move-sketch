import 'package:flutter/material.dart';
import '../../../utils/validators.dart';

class VersionDialogContentCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController androidStoreUrlController;
  final TextEditingController iosStoreUrlController;
  final TextEditingController releaseNotesController;

  const VersionDialogContentCard({
    super.key,
    required this.titleController,
    required this.androidStoreUrlController,
    required this.iosStoreUrlController,
    required this.releaseNotesController,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.announcement_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('업데이트 안내 팝업 문구', style: textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '팝업 제목 *',
                hintText: '새로운 버전이 출시되었습니다!',
                helperText: '업데이트 다이얼로그 상단에 표시되는 제목',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '팝업 제목을 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: androidStoreUrlController,
              decoration: const InputDecoration(
                labelText: 'Android Play Store URL (선택)',
                hintText: 'https://play.google.com/store/apps/details?id=com.neonsigntrap.move_sketch',
                helperText: '비워둘 시 Google Play 공식 스토어로 자동 연결됩니다.',
              ),
              validator: Validators.validateOptionalUrl,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: iosStoreUrlController,
              decoration: const InputDecoration(
                labelText: 'iOS App Store URL (선택)',
                hintText: 'https://apps.apple.com/kr/app/id6819965333',
                helperText: '비워둘 시 Apple App Store 공식 스토어로 자동 연결됩니다.',
              ),
              validator: Validators.validateOptionalUrl,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: releaseNotesController,
              minLines: 5,
              maxLines: 9,
              decoration: const InputDecoration(
                labelText: '릴리즈 노트',
                hintText: '- 새로운 기록 통계 기능 추가\n- 버그 수정 및 안정성 향상',
                helperText: '업데이트 안내 팝업 본문에 표시될 상세 변경 내역',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
