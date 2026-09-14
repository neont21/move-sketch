import 'package:flutter/material.dart';

class SketchCard extends StatelessWidget {
  final ImageProvider imageProvider;
  final String? caption;
  final bool isHome;
  final bool isGrid;

  const SketchCard({
    super.key,
    required this.imageProvider,
    this.caption,
    this.isHome = false,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: FractionallySizedBox(
        widthFactor: isGrid ? 0.9 : 0.8,
        child: AspectRatio(
          aspectRatio: caption != null ? 0.9 : 1,
          child: Container(
            padding: isGrid
                ? const EdgeInsets.all(4)
                : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.outlineVariant,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isHome
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                caption != null
                    ? Expanded(
                        child: Text(
                          caption!,
                          style: isHome
                              ? textTheme.titleLarge
                              : textTheme.titleMedium,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
