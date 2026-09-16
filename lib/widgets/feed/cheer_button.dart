import 'package:flutter/material.dart';
import '../../models/mock_user.dart';
import '../friends/user_list_dialog.dart';

class CheerButton extends StatefulWidget {
  final MockUser author;
  final MockUser user;
  final List<MockUser> cheeredUser;

  const CheerButton({
    super.key,
    required this.author,
    required this.user,
    required this.cheeredUser,
  });

  @override
  State<CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<CheerButton> {
  bool _isCheered = false;

  @override
  void initState() {
    super.initState();
    _isCheered = widget.cheeredUser.contains(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: () {
        if (widget.author.id == widget.user.id) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: UserListDialog(
                title: '응원한 친구',
                userList: widget.cheeredUser,
              ),
            ),
          );
        } else {
          setState(() {
            if (_isCheered) {
              widget.cheeredUser.remove(widget.user);
              _isCheered = false;
            } else {
              widget.cheeredUser.add(widget.user);
              _isCheered = true;
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        side: BorderSide(color: colorScheme.outline),
        backgroundColor: _isCheered
            ? colorScheme.primary
            : colorScheme.surfaceContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline_rounded,
              color: _isCheered
                  ? colorScheme.onPrimary
                  : colorScheme.tertiaryContainer,
              size: 28,
            ),
            Text(
              (widget.author.id == widget.user.id)
                  ? '응원 ${widget.cheeredUser.length}명'
                  : (_isCheered)
                  ? '응원했어요 ${widget.cheeredUser.length}'
                  : '응원하기 ${widget.cheeredUser.length}',
              style: textTheme.headlineSmall?.copyWith(
                color: _isCheered
                    ? colorScheme.onPrimary
                    : colorScheme.tertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
