import 'package:flutter/material.dart';

class SketchCard extends StatelessWidget {
  final ImageProvider _imageProvider;
  final String? _caption;

  const SketchCard({super.key, required this._imageProvider, this._caption});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: AspectRatio(
          aspectRatio: 0.9,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _caption ?? '',
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
