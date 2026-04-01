import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/workout_tracking_provider.dart';
import '../app_router.dart';
import '../widgets/app_drawer.dart';

class OutdoorWorkoutScreen extends StatelessWidget {
  const OutdoorWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(currentRouteName: AppRoute.outdoorWorkout.name),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Outdoor Workout'),
        actions: const [DrawerBackAction()],
      ),
      body: Consumer<WorkoutTrackingProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeroCard(phase: provider.workoutPhase),
              const SizedBox(height: 16),
              switch (provider.workoutPhase) {
                WorkoutPhase.idle => _IdlePhase(provider: provider),
                WorkoutPhase.active => _ActivePhase(provider: provider),
                WorkoutPhase.finished => _FinishedPhase(provider: provider),
              },
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final WorkoutPhase phase;

  const _HeroCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    final title = switch (phase) {
      WorkoutPhase.idle => 'Ready to go outside?',
      WorkoutPhase.active => 'Workout in progress',
      WorkoutPhase.finished => 'Workout summary',
    };

    final description = switch (phase) {
      WorkoutPhase.idle =>
        'Track a real outdoor run, walk, or ride with live GPS, elapsed time, and a full finish summary.',
      WorkoutPhase.active =>
        'Your timer is running and GPS updates can be refreshed while the workout is active.',
      WorkoutPhase.finished =>
        'Review your route, distance, pace, and the start and end coordinates captured during the workout.',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFECFEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.route_rounded,
            color: Colors.deepOrange,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdlePhase extends StatelessWidget {
  final WorkoutTrackingProvider provider;

  const _IdlePhase({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _PhaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(
              Icons.directions_run_rounded,
              color: Colors.deepOrange,
              size: 58,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track your outdoor run with GPS',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The permission popup appears only when you tap Start Run. This keeps the request tied to a clear user action.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if ((provider.errorMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            _ErrorBanner(message: provider.errorMessage!),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.isLoadingLocation
                  ? null
                  : provider.startWorkout,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: provider.isLoadingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                provider.isLoadingLocation ? 'Getting GPS Fix...' : 'Start Run',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivePhase extends StatelessWidget {
  final WorkoutTrackingProvider provider;

  const _ActivePhase({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PhaseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elapsed Time',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.formattedTime,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _MetricGrid(
                children: [
                  _MetricTile(
                    label: 'Current Lat',
                    value: _formatCoordinate(provider.currentPosition?.latitude),
                  ),
                  _MetricTile(
                    label: 'Current Lon',
                    value: _formatCoordinate(provider.currentPosition?.longitude),
                  ),
                  _MetricTile(
                    label: 'GPS Points',
                    value: '${provider.routePointCount}',
                  ),
                  _MetricTile(
                    label: 'Phase',
                    value: 'Active',
                  ),
                ],
              ),
              if ((provider.errorMessage ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: provider.errorMessage!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PhaseCard(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isLoadingLocation
                      ? null
                      : provider.updateLocation,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Update Location'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.canFinish && !provider.isLoadingLocation
                      ? provider.finishWorkout
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: provider.isLoadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    provider.isLoadingLocation ? 'Finishing...' : 'Finish Run',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinishedPhase extends StatelessWidget {
  final WorkoutTrackingProvider provider;

  const _FinishedPhase({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PhaseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Summary',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final metricsSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetricGrid(
                        children: [
                          _MetricTile(
                            label: 'Total Time',
                            value: provider.formattedTime,
                          ),
                          _MetricTile(
                            label: 'Straight Line',
                            value: provider.formattedStraightLineDistance,
                          ),
                          _MetricTile(
                            label: 'Route Distance',
                            value: provider.formattedRouteDistance,
                          ),
                          _MetricTile(
                            label: 'Average Pace',
                            value: provider.formattedPace,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SummaryLine(
                        label: 'Start Location',
                        value: _formatPosition(provider.startPosition),
                      ),
                      const SizedBox(height: 10),
                      _SummaryLine(
                        label: 'End Location',
                        value: _formatPosition(provider.endPosition),
                      ),
                      const SizedBox(height: 10),
                      _SummaryLine(
                        label: 'GPS Points Recorded',
                        value: '${provider.routePointCount}',
                      ),
                    ],
                  );

                  final pointsSection = _RoutePointPanel(
                    points: provider.routePoints,
                  );

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: math.max(0, constraints.maxWidth * 0.58),
                            child: metricsSection,
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: math.max(280, constraints.maxWidth * 0.34),
                            child: pointsSection,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (provider.routePointCount >= 2) ...[
          const SizedBox(height: 16),
          _PhaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route Preview',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Normalized path from recorded GPS coordinates. This is a visual route sketch, not a map or chart scale.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _RouteLegendItem(
                      color: Colors.green,
                      label: 'Start point',
                    ),
                    _RouteLegendItem(
                      color: Colors.redAccent,
                      label: 'Finish point',
                    ),
                    _RouteLegendItem(
                      color: Colors.deepOrange,
                      label: 'Recorded route',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _RoutePainter(provider.routePoints),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Distance values are calculated from the stored latitude and longitude points, not from the drawing itself.',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        if ((provider.errorMessage ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: provider.errorMessage!),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: provider.resetWorkout,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('New Workout'),
          ),
        ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final Widget child;

  const _PhaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<Widget> children;

  const _MetricGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children
          .map(
            (child) => SizedBox(
              width: (MediaQuery.of(context).size.width - 56) / 2,
              child: child,
            ),
          )
          .toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}

class _RoutePointPanel extends StatelessWidget {
  final List<Position> points;

  const _RoutePointPanel({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepOrange.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route Points',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap any recorded point to open its coordinates in your default browser or maps app.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 240,
            child: points.isEmpty
                ? const Center(
                    child: Text(
                      'No GPS points recorded.',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      itemCount: points.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final point = points[index];
                        final isStart = index == 0;
                        final isEnd = index == points.length - 1;
                        final label = isStart
                            ? 'Start'
                            : isEnd
                                ? 'Finish'
                                : 'Point ${index + 1}';

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _openPoint(context, point),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.deepOrange.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: isStart
                                              ? Colors.green
                                              : isEnd
                                                  ? Colors.redAccent
                                                  : Colors.deepOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 16,
                                        color: Colors.deepOrange,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lat: ${point.latitude.toStringAsFixed(5)}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Lon: ${point.longitude.toStringAsFixed(5)}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPoint(BuildContext context, Position point) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );
    final launchedExternally = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (launchedExternally) {
      return;
    }

    final launchedByPlatform = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );

    if (launchedByPlatform) {
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open these coordinates on this device.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _RouteLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _RouteLegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<Position> points;

  _RoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    const padding = 18.0;
    final usableWidth = math.max(1.0, size.width - (padding * 2));
    final usableHeight = math.max(1.0, size.height - (padding * 2));

    final latitudes = points.map((point) => point.latitude).toList();
    final longitudes = points.map((point) => point.longitude).toList();

    final minLat = latitudes.reduce(math.min);
    final maxLat = latitudes.reduce(math.max);
    final minLon = longitudes.reduce(math.min);
    final maxLon = longitudes.reduce(math.max);

    final latRange = math.max(0.000001, maxLat - minLat);
    final lonRange = math.max(0.000001, maxLon - minLon);

    Offset normalizePoint(Position point) {
      final x = padding + ((point.longitude - minLon) / lonRange) * usableWidth;
      final y =
          padding + (1 - ((point.latitude - minLat) / latRange)) * usableHeight;
      return Offset(x, y);
    }

    final routePaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final firstPoint = normalizePoint(points.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (final point in points.skip(1)) {
      final offset = normalizePoint(point);
      path.lineTo(offset.dx, offset.dy);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFFFFBF7),
    );
    canvas.drawPath(path, routePaint);

    final startDot = Paint()..color = Colors.green;
    final endDot = Paint()..color = Colors.redAccent;
    final labelStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (var index = 0; index < points.length; index += 1) {
      final point = points[index];
      final offset = normalizePoint(point);
      final isStart = index == 0;
      final isEnd = index == points.length - 1;
      final pointPaint = Paint()
        ..color = isStart
            ? Colors.green
            : isEnd
                ? Colors.redAccent
                : Colors.deepOrange;

      canvas.drawCircle(offset, 6, pointPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${index + 1}',
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelOffset = Offset(
        offset.dx + 8,
        offset.dy - textPainter.height - 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

String _formatCoordinate(double? value) {
  if (value == null) {
    return '--';
  }
  return value.toStringAsFixed(4);
}

String _formatPosition(Position? position) {
  if (position == null) {
    return 'Not recorded';
  }
  return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
}
