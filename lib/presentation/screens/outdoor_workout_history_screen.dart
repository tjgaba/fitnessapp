import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/workout_tracking_provider.dart';
import '../../models/outdoor_workout_record.dart';
import '../navigation/app_router.dart';
import '../widgets/app_drawer.dart';

class OutdoorWorkoutHistoryScreen extends StatefulWidget {
  const OutdoorWorkoutHistoryScreen({super.key});

  @override
  State<OutdoorWorkoutHistoryScreen> createState() =>
      _OutdoorWorkoutHistoryScreenState();
}

class _OutdoorWorkoutHistoryScreenState extends State<OutdoorWorkoutHistoryScreen> {
  final Set<String> _expandedDays = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.outdoorWorkoutHistory.name,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Outdoor Workout History'),
        actions: const [DrawerBackAction()],
      ),
      body: Consumer<WorkoutTrackingProvider>(
        builder: (context, provider, _) {
          if (!provider.hasHistory) {
            return const _EmptyHistoryState();
          }

          final groupedHistory = _groupHistoryByWeek(provider.history);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groupedHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = groupedHistory[index];
                final dayLabel = entry.key;
                final records = entry.value;
                final isExpanded = _expandedDays.contains(dayLabel);

              return _HistoryDaySection(
                dayLabel: dayLabel,
                records: records,
                isExpanded: isExpanded,
                onToggle: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedDays.remove(dayLabel);
                    } else {
                      _expandedDays.add(dayLabel);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryDaySection extends StatelessWidget {
  final String dayLabel;
  final List<OutdoorWorkoutRecord> records;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _HistoryDaySection({
    required this.dayLabel,
    required this.records,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final totalRouteDistance = records.fold<double>(
      0,
      (sum, record) => sum + record.routeDistanceMeters,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${records.length} workout(s) | ${_formatDistance(totalRouteDistance)} total route distance',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepOrange.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Minimize' : 'Expand',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.deepOrange,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!isExpanded)
            Text(
              '${records.length} workout(s) hidden. Expand to review this day.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            )
          else
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(record: record),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final OutdoorWorkoutRecord record;

  const _HistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final routeDistance = record.routeDistanceMeters > 0
        ? record.routeDistanceMeters
        : record.straightLineDistanceMeters;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDateTime(record.startedAt),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _formatDistance(routeDistance),
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HistoryChip(label: 'Time', value: _formatTime(record.elapsedSeconds)),
              _HistoryChip(
                label: 'Straight Line',
                value: _formatDistance(record.straightLineDistanceMeters),
              ),
              _HistoryChip(
                label: 'Route',
                value: _formatDistance(record.routeDistanceMeters),
              ),
              _HistoryChip(
                label: 'Points',
                value: '${record.routePoints.length}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _HistoryLine(
            label: 'Start',
            value: _formatPosition(record.startPosition),
          ),
          const SizedBox(height: 8),
          _HistoryLine(
            label: 'Finish',
            value: _formatPosition(record.endPosition),
          ),
          if (record.routePoints.length >= 2) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.deepOrange.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route Preview',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _MiniRoutePainter(record.routePoints),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLine extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.deepOrange.withValues(alpha: 0.16),
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                color: Colors.deepOrange,
                size: 40,
              ),
              SizedBox(height: 16),
              Text(
                'No outdoor workouts yet',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Finish an outdoor workout and it will appear here with distance, time, and coordinate snapshots.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniRoutePainter extends CustomPainter {
  final List<Position> points;

  _MiniRoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    const padding = 12.0;
    final usableWidth = size.width - (padding * 2);
    final usableHeight = size.height - (padding * 2);

    final latitudes = points.map((point) => point.latitude).toList();
    final longitudes = points.map((point) => point.longitude).toList();

    final minLat = latitudes.reduce((a, b) => a < b ? a : b);
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
    final minLon = longitudes.reduce((a, b) => a < b ? a : b);
    final maxLon = longitudes.reduce((a, b) => a > b ? a : b);

    final latRange = (maxLat - minLat).abs() < 0.000001
        ? 0.000001
        : (maxLat - minLat);
    final lonRange = (maxLon - minLon).abs() < 0.000001
        ? 0.000001
        : (maxLon - minLon);

    Offset normalize(Position point) {
      final x = padding + ((point.longitude - minLon) / lonRange) * usableWidth;
      final y =
          padding + (1 - ((point.latitude - minLat) / latRange)) * usableHeight;
      return Offset(x, y);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFFFFFDF9),
    );

    final path = Path();
    final first = normalize(points.first);
    path.moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final offset = normalize(point);
      path.lineTo(offset.dx, offset.dy);
    }

    final routePaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    canvas.drawCircle(first, 4, Paint()..color = Colors.green);
    canvas.drawCircle(
      normalize(points.last),
      4,
      Paint()..color = Colors.redAccent,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRoutePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

String _formatDateTime(DateTime value) {
  final month = _monthLabel(value.month);
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day $month ${value.year}  $hour:$minute';
}

List<MapEntry<String, List<OutdoorWorkoutRecord>>> _groupHistoryByWeek(
  List<OutdoorWorkoutRecord> history,
) {
  final grouped = <String, List<OutdoorWorkoutRecord>>{};

  for (final record in history) {
    final date = record.startedAt;
    final weekOfMonth = (((date.day - 1) ~/ 7) + 1).clamp(1, 5);
    final key = 'Week $weekOfMonth of ${_monthLabel(date.month)} ${date.year}';
    grouped.putIfAbsent(key, () => <OutdoorWorkoutRecord>[]).add(record);
  }

  return grouped.entries.toList();
}

String _monthLabel(int month) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String _formatTime(int elapsedSeconds) {
  final hours = elapsedSeconds ~/ 3600;
  final minutes = (elapsedSeconds % 3600) ~/ 60;
  final seconds = elapsedSeconds % 60;

  String twoDigits(int value) => value.toString().padLeft(2, '0');
  if (hours > 0) {
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
  return '${twoDigits(minutes)}:${twoDigits(seconds)}';
}

String _formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.round()} m';
  }
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

String _formatPosition(Position? value) {
  if (value == null) {
    return 'Not recorded';
  }
  return 'Lat: ${value.latitude.toStringAsFixed(4)}, Lon: ${value.longitude.toStringAsFixed(4)}';
}
