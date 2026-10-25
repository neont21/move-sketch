import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InquiryImagePickerSection extends StatelessWidget {
  final List<Uint8List> images;
  final int maxImageCount;
  final bool canAddMoreImages;
  final bool isSubmitting;
  final VoidCallback onPickImage;
  final ValueChanged<int> onRemoveImage;

  const InquiryImagePickerSection({
    super.key,
    required this.images,
    required this.maxImageCount,
    required this.canAddMoreImages,
    required this.isSubmitting,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진 첨부 (최대 $maxImageCount장, 장당 5MB 이하)',
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (canAddMoreImages) ...[
                GestureDetector(
                  onTap: isSubmitting ? null : onPickImage,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 26,
                          color: colorScheme.tertiaryContainer,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${images.length}/$maxImageCount',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.tertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              for (int index = 0; index < images.length; index++) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        images[index],
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: isSubmitting ? null : () => onRemoveImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (index < images.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}