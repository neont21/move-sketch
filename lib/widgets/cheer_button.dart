import 'package:flutter/material.dart';
import 'package:move_sketch/models/mock_user.dart';

import '../pages/cheered_user_modal.dart';

class CheerButton extends StatefulWidget {
  final MockUser _author;
  final MockUser _user;
  final List<MockUser> _cheeredUser;

  const CheerButton({super.key, required this._author, required this._user, required this._cheeredUser});

  @override
  State<CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<CheerButton> {
  bool _isCheered = false;

  @override
  void initState() {
    super.initState();
    _isCheered = widget._cheeredUser.contains(widget._user);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return
    ElevatedButton(
      onPressed: () {
        if (widget._author.id == widget._user.id) {
          // 응원 목록
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: CheeredUserModal(
                cheeredUser: widget._cheeredUser,
              ),
            ),
          );
        } else {
          // 응원하기
          setState(() {
            if (_isCheered) {
              widget._cheeredUser.remove(widget._user);
              _isCheered = false;
            } else {
              widget._cheeredUser.add(widget._user);
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
              (widget._author.id == widget._user.id)
                  ? '응원 ${widget._cheeredUser.length}명'
                  : (_isCheered)
                  ? '응원했어요 ${widget._cheeredUser.length}'
                  : '응원하기 ${widget._cheeredUser.length}',
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
