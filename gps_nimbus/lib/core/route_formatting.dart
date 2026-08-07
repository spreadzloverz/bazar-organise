import '../domain/model/route_option.dart';
import '../domain/model/route_segment.dart';

/// Mise en forme partagée entre l'interface graphique et le harnais
/// en ligne de commande, pour que les deux affichent exactement la
/// même chose.
class RouteFormatting {
  const RouteFormatting._();

  /// « 1 h 07 » ou « 24 min ».
  static String duration(Duration duration) {
    final totalMinutes = (duration.inSeconds / 60).round();
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours h ${minutes.toString().padLeft(2, '0')}';
  }

  /// « 850 m » ou « 12,4 km ».
  static String distance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  /// « aucune », « 1 correspondance », « 2 correspondances ».
  static String transfers(int count) {
    if (count == 0) return 'aucune correspondance';
    return count == 1 ? '1 correspondance' : '$count correspondances';
  }

  /// Description d'un tronçon : « MÉTRO 1 — Châtelet → Bastille (6 min) ».
  static String segment(RouteSegment segment) {
    final label = segment.type.isWaiting
        ? 'Attente${segment.line != null ? ' ${segment.line!.displayName}' : ''}'
        : segment.line?.displayName ?? segment.type.longLabel;
    final where = segment.type.isWaiting
        ? segment.origin.label
        : '${segment.origin.label} → ${segment.destination.label}';
    final measures = segment.type.isWaiting
        ? duration(segment.duration)
        : '${distance(segment.distanceMeters)}, ${duration(segment.duration)}';
    return '$label — $where ($measures)';
  }

  /// Résumé d'un itinéraire sur une ligne.
  static String summary(RouteOption route) {
    return '${duration(route.totalDuration)} · '
        '${route.sequenceLabel} · '
        'skate ${distance(route.skateDistanceMeters)} · '
        'marche ${distance(route.walkDistanceMeters)} · '
        '${transfers(route.transferCount)}';
  }
}
