import 'package:flutter/material.dart';
import 'package:move_sketch/models/mock_sketch_list.dart';
import 'package:move_sketch/widgets/sketch_card.dart';

class ProfileGrid extends StatelessWidget {
  final String userId;
  final ValueChanged<int> onTap;
  final MockSketchList sketchList;
  const ProfileGrid({
    super.key,
    required this.userId,
    required this.sketchList,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: sketchList.sketches.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onTap(index),
        child: SketchCard(
          imageProvider: AssetImage('assets/sample_sketch.png'),
          isGrid: true,
        ),
      ),
    );
  }
}
