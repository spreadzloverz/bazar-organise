import 'package:flutter/material.dart';

import '../../app.dart';
import '../../domain/model/segment_type.dart';

/// Couleurs et icônes associées à chaque mode, partagées par tous les
/// écrans pour que le vocabulaire visuel reste constant.
class SegmentVisuals {
  const SegmentVisuals._();

  static Color color(SegmentType type) {
    if (type.isSkate) return NimbusTheme.skateColor;
    if (type.isWalking) return NimbusTheme.walkColor;
    if (type.isTransit) return NimbusTheme.transitColor;
    return Colors.grey;
  }

  static IconData icon(SegmentType type) {
    switch (type) {
      case SegmentType.walkingRoute:
      case SegmentType.transferWalk:
        return Icons.directions_walk;
      case SegmentType.skate:
        return Icons.skateboarding;
      case SegmentType.metro:
        return Icons.subway;
      case SegmentType.rer:
        return Icons.train;
      case SegmentType.tram:
        return Icons.tram;
      case SegmentType.bus:
        return Icons.directions_bus;
      case SegmentType.waiting:
        return Icons.schedule;
    }
  }
}

/// Pastille représentant un mode dans la séquence d'un trajet.
class ModeChip extends StatelessWidget {
  const ModeChip({super.key, required this.type, this.lineName});

  final SegmentType type;
  final String? lineName;

  @override
  Widget build(BuildContext context) {
    final color = SegmentVisuals.color(type);
    final text = lineName == null || lineName!.isEmpty
        ? type.shortLabel
        : '${type.shortLabel} $lineName';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(SegmentVisuals.icon(type), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
