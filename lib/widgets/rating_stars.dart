import 'package:flutter/material.dart';

import '../styles/app_colors.dart';

/// Row of 5 stars showing/collecting a 1-5 rating.
///
/// Pass [onChanged] to make it interactive (tappable stars); omit it for
/// a read-only display of an existing rating.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 32,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final icon = Icon(
          starValue <= value ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.secondary,
          size: size,
        );

        if (onChanged == null) return icon;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged!(starValue),
          child: Padding(padding: const EdgeInsets.all(2), child: icon),
        );
      }),
    );
  }
}
