import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/models/mock_sketch_list.dart';
import 'package:move_sketch/widgets/sketch_card.dart';

class ProfileGrid extends StatefulWidget {
  final String _userId;
  const ProfileGrid({super.key, required this._userId});

  @override
  State<ProfileGrid> createState() => _ProfileGridState();
}

class _ProfileGridState extends State<ProfileGrid> {
  late MockSketchList _sketchList;

  @override
  void initState() {
    super.initState();
    _sketchList = MockSketchList.byUser(widget._userId);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _sketchList.sketches.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          context.go('/me/post/${_sketchList.sketches[index].sketchId}');
        },
        child: SketchCard(
          imageProvider: AssetImage('assets/sample_sketch.png'),
          isGrid: true,
        ),
      ),
    );
  }
}
