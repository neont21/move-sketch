import 'package:flutter/material.dart';
import '../../../domain/models/social/sketch_post.dart';
import '../../../utils/image_provider_utils.dart';
import '../../session/widgets/sketch_card.dart';

class ProfileGrid extends StatelessWidget {
  final String userId;
  final ValueChanged<int> onTap;
  final List<SketchPost> sketches;

  const ProfileGrid({
    super.key,
    required this.userId,
    required this.sketches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: sketches.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTap(index),
          child: SketchCard(
            imageProvider: ImageProviderUtils.resolve(
              sketches[index].sketchUrl,
            ),
            isGrid: true,
          ),
        ),
      ),
    );
  }
}
