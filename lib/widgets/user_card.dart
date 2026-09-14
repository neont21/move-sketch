import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mock_user.dart';

class UserCard extends StatelessWidget {
  final MockUser user;
  final bool isFriend;
  final bool isRequested;
  final bool isSent;
  final bool onSearch;
  final bool onRecommend;

  const UserCard({
    super.key,
    required this.user,
    this.isFriend = false,
    this.isRequested = false,
    this.isSent = false,
    this.onSearch = false,
    this.onRecommend = false,
  });

  Widget _buildTitle(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (onSearch || (isRequested && !onRecommend)) {
      return Text(user.name, style: textTheme.bodyMedium);
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: user.name, style: textTheme.bodyMedium),
            TextSpan(text: ' '),
            TextSpan(text: user.id, style: textTheme.labelMedium),
          ],
        ),
      );
    }
  }

  Widget _buildSubtitle(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    if (onSearch || (isRequested && !onRecommend)) {
      return Text(user.id, style: textTheme.labelMedium);
    } else if (isFriend) {
      return Text('오늘 공유함', style: textTheme.labelMedium);
    } else if (onRecommend) {
      return Text('~~님과 아는 사이', style: textTheme.labelMedium);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTrailing(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (isRequested) {
      return Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            child: Text('거절', style: textTheme.bodySmall),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
              '수락',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    } else if (isSent) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: Text('요청 취소', style: textTheme.bodySmall),
      );
    } else if (isFriend) {
      return Icon(Icons.chevron_right, color: colorScheme.tertiaryContainer);
    } else {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: Text(
          '친구 요청',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push('/profile/${user.id}');
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.imageURL != null
            ? NetworkImage(user.imageURL!)
            : AssetImage('assets/default_profile.png'),
      ),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
    );
  }
}
