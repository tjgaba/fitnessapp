import 'package:flutter/material.dart';
import '../app_router.dart';
import '../models/user_profile.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/app_drawer.dart';
import '../widgets/metric_card.dart';
import '../widgets/profile_completeness.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final UserProfile _profile = UserProfile();
  bool _assessmentExpanded = true;
  bool _goalExpanded = true;
  bool _progressExpanded = true;
  bool _personalDetailsExpanded = true;
  bool _recommendationsExpanded = true;

  // Progress stats (mock — will come from real data layer later)
  final double _caloriesBurned = 1840;
  final double _projectedFatLoss = 0.24;
  final double _workoutProgress = 0.65;

  double get _bmi =>
      calculateBmi(_profile.weightKg, _profile.heightCm);
  String get _bmiCat => bmiCategory(_bmi);
  Color get _bmiColor {
    if (_bmi < 18.5) return Colors.blueAccent;
    if (_bmi < 25.0) return Colors.green;
    if (_bmi < 30.0) return Colors.orange;
    return Colors.redAccent;
  }

  double get _profileCompleteness => 0.75;
  double get _weightChange =>
      _profile.weightKg - _profile.initialWeightKg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.assessment.name,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        title: const Text(
          'Profile & Assessment',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4),
        ),
        elevation: 0,
        actions: const [DrawerBackAction()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileBanner(),
            const SizedBox(height: 20),

            _buildCollapsibleSection(
              title: 'Assessment Results',
              icon: Icons.analytics_outlined,
              color: _bmiColor,
              expanded: _assessmentExpanded,
              onToggle: () =>
                  setState(() => _assessmentExpanded = !_assessmentExpanded),
              child: _buildAssessmentResult(),
            ),
            const SizedBox(height: 20),

            _buildCollapsibleSection(
              title: 'My Goal',
              icon: Icons.flag_outlined,
              color: Colors.green,
              expanded: _goalExpanded,
              onToggle: () => setState(() => _goalExpanded = !_goalExpanded),
              child: _buildGoalSection(),
            ),
            const SizedBox(height: 20),

            _buildCollapsibleSection(
              title: 'Progress Tracking',
              icon: Icons.trending_up,
              color: Colors.pinkAccent,
              expanded: _progressExpanded,
              onToggle: () =>
                  setState(() => _progressExpanded = !_progressExpanded),
              child: _buildProgressTracking(),
            ),
            const SizedBox(height: 20),

            _buildCollapsibleSection(
              title: 'Personal Details',
              icon: Icons.person_outline,
              color: Colors.blueAccent,
              expanded: _personalDetailsExpanded,
              onToggle: () => setState(
                () => _personalDetailsExpanded = !_personalDetailsExpanded,
              ),
              child: _buildPersonalDetails(),
            ),
            const SizedBox(height: 20),

            _buildCollapsibleSection(
              title: 'Exercise Recommendations',
              icon: Icons.recommend_outlined,
              color: Colors.orange,
              expanded: _recommendationsExpanded,
              onToggle: () => setState(
                () => _recommendationsExpanded = !_recommendationsExpanded,
              ),
              child: _buildRecommendations(),
            ),
            const SizedBox(height: 20),

            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── 1. Profile Summary Banner ──────────────────────────────────────────

  Widget _buildProfileBanner() {
    return _card(
      color: Colors.blueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.blueAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 10)
                  ],
                ),
                child: const Icon(Icons.person,
                    color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profile.name,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(_profile.goal,
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // BMI badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: _bmiColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: _bmiColor.withValues(alpha: 0.3),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: [
                    Text(_bmi.toStringAsFixed(1),
                        style: TextStyle(
                            color: _bmiColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('BMI',
                        style: TextStyle(
                            color: _bmiColor.withValues(alpha: 0.7),
                            fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              MetricCard(
                  label: 'Weight',
                  value: '${_profile.weightKg.toInt()} kg',
                  sub: 'current',
                  color: Colors.blueAccent),
              const SizedBox(width: 8),
              MetricCard(
                  label: 'Target',
                  value: '${_profile.targetWeightKg.toInt()} kg',
                  sub: 'goal',
                  color: Colors.green),
              const SizedBox(width: 8),
              MetricCard(
                  label: 'BMI Status',
                  value: _bmiCat,
                  sub: '',
                  color: _bmiColor),
            ],
          ),
          const SizedBox(height: 14),
          ProfileCompleteness(value: _profileCompleteness),
        ],
      ),
    );
  }

  // ── 2. Personal Details ────────────────────────────────────────────────

  Widget _buildPersonalDetails() {
    return _card(
      color: Colors.blueAccent,
      child: Column(
        children: [
          _InputRow(
              label: 'Name',
              value: _profile.name,
              icon: Icons.badge_outlined,
              color: Colors.blueAccent,
              onEdit: () => _editText('Name', _profile.name,
                  (v) => setState(() => _profile.name = v))),
          _divider(),
          _InputRow(
              label: 'Age',
              value: '${_profile.age} yrs',
              icon: Icons.cake_outlined,
              color: Colors.blueAccent,
              onEdit: () => _editSlider('Age', _profile.age.toDouble(),
                  10, 100, (v) => setState(() => _profile.age = v.toInt()))),
          _divider(),
          _InputRow(
              label: 'Gender',
              value: _profile.gender,
              icon: Icons.wc_outlined,
              color: Colors.blueAccent,
              onEdit: () => _editPicker(
                  'Gender',
                  ['Male', 'Female', 'Other'],
                  _profile.gender,
                  (v) => setState(() => _profile.gender = v))),
          _divider(),
          _InputRow(
              label: 'Height',
              value: '${_profile.heightCm.toInt()} cm',
              icon: Icons.height,
              color: Colors.blueAccent,
              onEdit: () => _editSlider('Height (cm)', _profile.heightCm,
                  120, 220, (v) => setState(() => _profile.heightCm = v))),
          _divider(),
          _InputRow(
              label: 'Current Weight',
              value: '${_profile.weightKg.toInt()} kg',
              icon: Icons.monitor_weight_outlined,
              color: Colors.blueAccent,
              onEdit: () => _editSlider('Weight (kg)', _profile.weightKg,
                  30, 200, (v) => setState(() => _profile.weightKg = v))),
          _divider(),
          _InputRow(
              label: 'Target Weight',
              value: '${_profile.targetWeightKg.toInt()} kg',
              icon: Icons.my_location,
              color: Colors.green,
              onEdit: () => _editSlider(
                  'Target Weight (kg)',
                  _profile.targetWeightKg,
                  30,
                  200,
                  (v) => setState(() => _profile.targetWeightKg = v))),
          _divider(),
          _InputRow(
              label: 'Activity Level',
              value: _profile.activityLevel,
              icon: Icons.directions_walk,
              color: Colors.orange,
              onEdit: () => _editPicker(
                  'Activity Level',
                  [
                    'Sedentary',
                    'Light',
                    'Moderate',
                    'Active',
                    'Very Active'
                  ],
                  _profile.activityLevel,
                  (v) => setState(() => _profile.activityLevel = v))),
          _divider(),
          _InputRow(
              label: 'Resting Heart Rate',
              value: '${_profile.restingHeartRate.toInt()} bpm',
              icon: Icons.favorite_border,
              color: Colors.pinkAccent,
              onEdit: () => _editSlider(
                  'Heart Rate (bpm)',
                  _profile.restingHeartRate,
                  40,
                  120,
                  (v) => setState(
                      () => _profile.restingHeartRate = v))),
        ],
      ),
    );
  }

  // ── 3. Goal Section ────────────────────────────────────────────────────

  Widget _buildGoalSection() {
    const goals = [
      {'label': 'Lose Weight', 'icon': Icons.trending_down, 'color': Colors.pinkAccent},
      {'label': 'Build Muscle', 'icon': Icons.fitness_center, 'color': Colors.blueAccent},
      {'label': 'Improve Endurance', 'icon': Icons.directions_run, 'color': Colors.orange},
      {'label': 'Maintain Fitness', 'icon': Icons.balance, 'color': Colors.green},
      {'label': 'Improve Flexibility', 'icon': Icons.self_improvement, 'color': Colors.purple},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: goals.map((g) {
        final label = g['label'] as String;
        final icon = g['icon'] as IconData;
        final color = g['color'] as Color;
        final selected = _profile.goal == label;
        return GestureDetector(
          onTap: () => setState(() => _profile.goal = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected ? color : Colors.black12,
                  width: selected ? 1.5 : 1),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.28), blurRadius: 10)
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: selected ? color : Colors.black38, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: selected ? color : Colors.black54,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 4. Assessment Result ───────────────────────────────────────────────

  Widget _buildAssessmentResult() {
    String interp;
    String suggestion;
    if (_bmi < 18.5) {
      interp =
          'Your BMI suggests you may be underweight. Focus on building healthy mass through nutrition and strength training.';
      suggestion =
          'Prioritise Strength training with nutrient-dense meals.';
    } else if (_bmi < 25.0) {
      interp =
          'Great news — your BMI is in the normal range! Maintain your current routine for optimal health.';
      suggestion =
          'A balanced mix of all four workout categories will keep you in excellent shape.';
    } else if (_bmi < 30.0) {
      interp =
          'Your BMI is slightly above normal. A combination of cardio and strength training can help.';
      suggestion =
          'Prioritise Cardio and HIIT. Strength training preserves muscle while you lose fat.';
    } else {
      interp =
          'Your BMI indicates obesity. Start with low-impact exercise and consider consulting a medical professional.';
      suggestion =
          'Begin with Flexibility and light Cardio, then gradually increase intensity.';
    }

    return _card(
      color: _bmiColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _glowBadge('BMI: ${_bmi.toStringAsFixed(1)}', _bmiColor),
              const SizedBox(width: 10),
              _glowBadge(_bmiCat, _bmiColor, small: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(interp,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 13, height: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_outlined,
                    color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(suggestion,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            height: 1.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Exercise Recommendations ────────────────────────────────────────

  Widget _buildRecommendations() {
    final recs = _recommendations();
    return Column(
      children: recs.map((r) {
        final color = r['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.14),
                  blurRadius: 6,
                  spreadRadius: 1)
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8)
                  ],
                ),
                child: Icon(r['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['category'] as String,
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                        '${r['frequency']}x/week · ${r['duration']} · ${r['intensity']}',
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: color.withValues(alpha: 0.4), width: 1),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 5)
                  ],
                ),
                child: Text(r['intensity'] as String,
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _recommendations() {
    switch (_profile.goal) {
      case 'Lose Weight':
        return [
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 3, 'duration': '30 min', 'intensity': 'High'},
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 4, 'duration': '40 min', 'intensity': 'Moderate'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '45 min', 'intensity': 'Moderate'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.greenAccent, 'frequency': 2, 'duration': '20 min', 'intensity': 'Low'},
        ];
      case 'Build Muscle':
        return [
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 4, 'duration': '60 min', 'intensity': 'High'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 2, 'duration': '20 min', 'intensity': 'High'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.greenAccent, 'frequency': 3, 'duration': '20 min', 'intensity': 'Low'},
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 1, 'duration': '30 min', 'intensity': 'Light'},
        ];
      case 'Improve Endurance':
        return [
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 5, 'duration': '45 min', 'intensity': 'Moderate'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 2, 'duration': '30 min', 'intensity': 'High'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '40 min', 'intensity': 'Moderate'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.greenAccent, 'frequency': 2, 'duration': '20 min', 'intensity': 'Low'},
        ];
      case 'Improve Flexibility':
        return [
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.greenAccent, 'frequency': 5, 'duration': '30 min', 'intensity': 'Low'},
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 3, 'duration': '30 min', 'intensity': 'Light'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '40 min', 'intensity': 'Moderate'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 1, 'duration': '20 min', 'intensity': 'Moderate'},
        ];
      default: // Maintain Fitness
        return [
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 3, 'duration': '30 min', 'intensity': 'Moderate'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '45 min', 'intensity': 'Moderate'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 2, 'duration': '25 min', 'intensity': 'Moderate'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.greenAccent, 'frequency': 2, 'duration': '20 min', 'intensity': 'Low'},
        ];
    }
  }

  // ── 6. Progress Tracking ─────────────────────────────────────────────

  Widget _buildProgressTracking() {
    return _card(
      color: Colors.pinkAccent,
      child: Column(
        children: [
          Row(
            children: [
              MetricCard(
                  label: 'Initial Weight',
                  value: '${_profile.initialWeightKg.toInt()} kg',
                  sub: 'baseline',
                  color: Colors.blueAccent),
              const SizedBox(width: 8),
              MetricCard(
                  label: 'Current Weight',
                  value: '${_profile.weightKg.toInt()} kg',
                  sub: 'recorded',
                  color: Colors.green),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Change',
                value:
                    '${_weightChange >= 0 ? '+' : ''}${_weightChange.toStringAsFixed(1)} kg',
                sub: 'actual',
                color: _weightChange <= 0 ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              MetricCard(
                  label: 'Calories Burned',
                  value: '${_caloriesBurned.toInt()} kcal',
                  sub: 'estimated',
                  color: Colors.orange),
              const SizedBox(width: 8),
              MetricCard(
                  label: 'Est. Fat Loss',
                  value: '~$_projectedFatLoss kg',
                  sub: 'projected',
                  color: Colors.pinkAccent),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Workout Completion',
                  style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text('${(_workoutProgress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _workoutProgress,
              backgroundColor: Colors.green.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '* Values are estimates. Update your weight regularly for more accurate progress tracking.',
            style: TextStyle(
                color: Colors.black.withValues(alpha: 0.35),
                fontSize: 10,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ── 7. Action Buttons ─────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        _ActionButton(
          label: 'SAVE PROFILE',
          icon: Icons.save_outlined,
          color: Colors.blueAccent,
          onTap: () => _snack('Profile saved!', Colors.blueAccent),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'RECALCULATE ASSESSMENT',
          icon: Icons.refresh,
          color: Colors.orange,
          onTap: () {
            setState(() {});
            _snack('Assessment updated!', Colors.orange);
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'UPDATE WEIGHT  –  WEEKLY CHECK-IN',
          icon: Icons.monitor_weight_outlined,
          color: Colors.green,
          onTap: () => _editSlider(
              'Update Progress — Current Weight (kg)',
              _profile.weightKg,
              30,
              200,
              (v) => setState(() => _profile.weightKg = v)),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'AI COACH  (COMING SOON)',
          icon: Icons.psychology_outlined,
          color: Colors.purple,
          onTap: () => _snack('AI Coach — coming soon!', Colors.purple),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'NOTIFICATIONS  (COMING SOON)',
          icon: Icons.notifications_outlined,
          color: Colors.black38,
          onTap: () =>
              _snack('Notifications — coming soon!', Colors.black54),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _card({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 1)
        ],
      ),
      child: child,
    );
  }

  Widget _glowBadge(String text, Color color, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 12 : 16, vertical: small ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 8)
        ],
      ),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontSize: small ? 14 : 18,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4)),
      ],
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader(title, icon, color)),
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
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        expanded ? 'Minimize' : 'Expand',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: color,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (expanded)
          child
        else
          Text(
            '$title hidden',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget _divider() =>
      Divider(color: Colors.black.withValues(alpha: 0.06), height: 1);

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color.withValues(alpha: 0.85),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _editText(
      String label, String initial, Function(String) onSave) {
    final ctrl = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editSlider(String label, double initial, double min, double max,
      Function(double) onSave) {
    double current = initial;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(current.toInt().toString(),
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold)),
              Slider(
                value: current,
                min: min,
                max: max,
                onChanged: (v) => setS(() => current = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                onSave(current);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editPicker(String label, List<String> options, String current,
      Function(String) onSave) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((opt) => ListTile(
                    title: Text(opt),
                    trailing: opt == current
                        ? const Icon(Icons.check,
                            color: Colors.blueAccent)
                        : null,
                    onTap: () {
                      onSave(opt);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Input Row ─────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onEdit;

  const _InputRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.black45, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: color.withValues(alpha: 0.45), width: 1),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 5)
                ],
              ),
              child: Text('Edit',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _pressed = true);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) setState(() => _pressed = false);
          });
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color:
                Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withValues(alpha: _pressed ? 0.45 : 0.18),
                blurRadius: _pressed ? 18 : 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 18),
              const SizedBox(width: 10),
              Text(widget.label,
                  style: TextStyle(
                      color: widget.color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
