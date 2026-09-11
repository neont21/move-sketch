import 'package:flutter/material.dart';

class SketchCard extends StatelessWidget {
  final ImageProvider _imageProvider;
  final String? _caption;
  final bool _isHome;
  final bool _isGrid;

  const SketchCard({super.key, required this._imageProvider, this._caption, this._isHome=false, this._isGrid=false});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: FractionallySizedBox(
        widthFactor: _isGrid ? 0.9 : 0.8,
        child: AspectRatio(
          aspectRatio: _caption != null ? 0.9 : 1,
          child: Container(
            padding: _isGrid ? const EdgeInsets.all(4) : const EdgeInsets.all(12),
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
              crossAxisAlignment: _isHome ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                    style: _isHome ? textTheme.titleLarge : textTheme.titleMedium,
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
