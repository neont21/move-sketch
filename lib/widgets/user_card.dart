import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mock_user.dart';

class UserCard extends StatelessWidget {
  final MockUser _user;
  final bool _isFriend;
  final bool _isRequested;
  final bool _isSent;
  final bool _onSearch;
  final bool _onRecommend;

  const UserCard({
    super.key,
    required this._user,
    this._isFriend = false,
    this._isRequested = false,
    this._isSent = false,
    this._onSearch = false,
    this._onRecommend = false,
  });

  Widget _buildTitle(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    if (_onSearch || (_isRequested && !_onRecommend)) {
      return Text(_user.name, style: textTheme.bodyMedium);
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: _user.name, style: textTheme.bodyMedium),
            TextSpan(text: ' '),
            TextSpan(text: _user.id, style: textTheme.labelMedium),
          ],
        ),
      );
    }
  }

  Widget _buildSubtitle(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    if (_onSearch || (_isRequested && !_onRecommend)) {
      return Text(_user.id, style: textTheme.labelMedium);
    } else if (_isFriend) {
      return Text('오늘 공유함', style: textTheme.labelMedium);
    } else if (_onRecommend) {
      return Text('~~님과 아는 사이', style: textTheme.labelMedium);
    } else {
      return Container();
    }
  }

  Widget _buildTrailing(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_isRequested) {
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
    } else if (_isSent) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: Text('요청 취소', style: textTheme.bodySmall),
      );
    } else if (_isFriend) {
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
        context.push('/profile/${_user.id}');
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: _user.imageURL != null
            ? NetworkImage(_user.imageURL!)
            : AssetImage('assets/default_profile.png'),
      ),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
    );
  }
}
