import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_router.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/profile_provider.dart';
import '../../domain/providers/routine_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/metric_card.dart';
import '../widgets/profile_completeness.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  bool _assessmentExpanded = false;
  bool _goalExpanded = false;
  bool _progressExpanded = false;
  bool _personalDetailsExpanded = false;
  bool _preferencesExpanded = false;
  bool _recommendationsExpanded = false;
  final double _caloriesBurned = 1840;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final routine = context.watch<RoutineProvider>();
    final bmiColor = _bmiColor(profile.bmi);
    final isOnboarding = !profile.hasEssentialProfileDetails;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(currentRouteName: AppRoute.assessment.name),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        elevation: 0,
        actions: const [DrawerBackAction()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOnboarding) ...[
              _buildProfileCompletionBanner(profile),
              const SizedBox(height: 20),
            ],
            _buildProfileBanner(profile, bmiColor),
            const SizedBox(height: 20),
            _buildAccountCard(auth),
            const SizedBox(height: 20),
            _buildCollapsibleSection(
              title: 'Assessment Results',
              icon: Icons.analytics_outlined,
              color: bmiColor,
              expanded: _assessmentExpanded,
              onToggle: () => setState(() => _assessmentExpanded = !_assessmentExpanded),
              child: _buildAssessmentResult(profile, bmiColor),
            ),
            const SizedBox(height: 20),
            _buildCollapsibleSection(
              title: 'My Goal',
              icon: Icons.flag_outlined,
              color: Colors.green,
              expanded: _goalExpanded,
              onToggle: () => setState(() => _goalExpanded = !_goalExpanded),
              child: _buildGoalSection(profile),
            ),
            const SizedBox(height: 20),
            _buildCollapsibleSection(
              title: 'Progress Tracking',
              icon: Icons.trending_up,
              color: Colors.pinkAccent,
              expanded: _progressExpanded,
              onToggle: () => setState(() => _progressExpanded = !_progressExpanded),
              child: _buildProgressTracking(profile, routine),
            ),
            const SizedBox(height: 20),
            _buildCollapsibleSection(
              title: 'Personal Details',
              icon: Icons.person_outline,
              color: Colors.blueAccent,
              expanded: _personalDetailsExpanded,
              onToggle: () => setState(() => _personalDetailsExpanded = !_personalDetailsExpanded),
              child: _buildPersonalDetails(profile),
            ),
            const SizedBox(height: 20),
            _buildCollapsibleSection(
              title: 'Preferences',
              icon: Icons.tune,
              color: Colors.teal,
              expanded: _preferencesExpanded,
              onToggle: () => setState(() => _preferencesExpanded = !_preferencesExpanded),
              child: _buildPreferences(profile),
            ),
            const SizedBox(height: 20),
            _buildCollapsibleSection(
              title: 'Exercise Recommendations',
              icon: Icons.recommend_outlined,
              color: Colors.orange,
              expanded: _recommendationsExpanded,
              onToggle: () => setState(() => _recommendationsExpanded = !_recommendationsExpanded),
              child: _buildRecommendations(profile),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(profile),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBanner(ProfileProvider profile, Color bmiColor) {
    return _card(
      color: Colors.blueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(profile.goal, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _badge(profile.bmi.toStringAsFixed(1), 'BMI', bmiColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              MetricCard(label: 'Weight', value: profile.formatWeight(profile.weightKg), sub: 'current', color: Colors.blueAccent),
              const SizedBox(width: 8),
              MetricCard(label: 'Target', value: profile.formatWeight(profile.targetWeightKg), sub: 'goal', color: Colors.green),
              const SizedBox(width: 8),
              MetricCard(label: 'BMI Status', value: profile.bmiCategoryLabel, sub: '', color: bmiColor),
            ],
          ),
          const SizedBox(height: 14),
          ProfileCompleteness(value: profile.profileCompleteness),
        ],
      ),
    );
  }

  Widget _buildAccountCard(AuthProvider auth) {
    final userEmail = auth.userEmail ?? 'No signed-in email';
    final lastSignIn = auth.lastSignInTime == null
        ? 'Unavailable'
        : _formatDateTime(auth.lastSignInTime!);

    return _card(
      color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _InputRow(
            label: 'Signed In As',
            value: userEmail,
            icon: Icons.alternate_email,
            color: Colors.indigo,
            onEdit: _noopEdit,
          ),
          _divider(),
          _InputRow(
            label: 'Last Signed In',
            value: lastSignIn,
            icon: Icons.schedule,
            color: Colors.indigo,
            onEdit: _noopEdit,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(auth),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionBanner(ProfileProvider profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFECFCCB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete your profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your age, height, current weight, target weight, and initial weight so the app can personalize your fitness dashboard and recommendations.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: profile.profileCompleteness,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(profile.profileCompleteness * 100).round()}% complete',
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(ProfileProvider profile) {
    return _card(
      color: Colors.blueAccent,
      child: Column(
        children: [
          _InputRow(label: 'Name', value: profile.name, icon: Icons.badge_outlined, color: Colors.blueAccent, onEdit: () => _editText('Name', profile.name, (value) => context.read<ProfileProvider>().updateName(value))),
          _divider(),
          _InputRow(label: 'Age', value: '${profile.age} yrs', icon: Icons.cake_outlined, color: Colors.blueAccent, onEdit: () => _editSlider('Age', profile.age.toDouble(), 10, 100, onSave: (value) => context.read<ProfileProvider>().updateAge(value.toInt()))),
          _divider(),
          _InputRow(label: 'Gender', value: profile.gender, icon: Icons.wc_outlined, color: Colors.blueAccent, onEdit: () => _editPicker('Gender', const ['Male', 'Female', 'Other'], profile.gender, (value) => context.read<ProfileProvider>().updateGender(value))),
          _divider(),
          _InputRow(label: 'Height', value: '${profile.heightCm.toInt()} cm', icon: Icons.height, color: Colors.blueAccent, onEdit: () => _editSlider('Height (cm)', profile.heightCm, 120, 220, onSave: (value) => context.read<ProfileProvider>().updateHeightCm(value))),
          _divider(),
          _InputRow(label: 'Current Weight', value: profile.formatWeight(profile.weightKg), icon: Icons.monitor_weight_outlined, color: Colors.blueAccent, onEdit: () => _editSlider('Current Weight (kg)', profile.weightKg, 30, 200, onSave: (value) => context.read<ProfileProvider>().updateWeightKg(value))),
          _divider(),
          _InputRow(label: 'Target Weight', value: profile.formatWeight(profile.targetWeightKg), icon: Icons.my_location, color: Colors.green, onEdit: () => _editSlider('Target Weight (kg)', profile.targetWeightKg, 30, 200, onSave: (value) => context.read<ProfileProvider>().updateTargetWeightKg(value))),
          _divider(),
          _InputRow(label: 'Initial Weight', value: profile.formatWeight(profile.initialWeightKg), icon: Icons.flag_circle_outlined, color: Colors.orange, onEdit: () => _editSlider('Initial Weight (kg)', profile.initialWeightKg, 30, 200, onSave: (value) => context.read<ProfileProvider>().updateInitialWeightKg(value))),
          _divider(),
          _InputRow(label: 'Activity Level', value: profile.activityLevel, icon: Icons.directions_walk, color: Colors.orange, onEdit: () => _editPicker('Activity Level', const ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'], profile.activityLevel, (value) => context.read<ProfileProvider>().updateActivityLevel(value))),
          _divider(),
          _InputRow(label: 'Resting Heart Rate', value: '${profile.restingHeartRate.toInt()} bpm', icon: Icons.favorite_border, color: Colors.pinkAccent, onEdit: () => _editSlider('Heart Rate (bpm)', profile.restingHeartRate, 40, 120, onSave: (value) => context.read<ProfileProvider>().updateRestingHeartRate(value))),
        ],
      ),
    );
  }

  Widget _buildGoalSection(ProfileProvider profile) {
    const goals = [
      ('Lose Weight', Icons.trending_down, Colors.pinkAccent),
      ('Build Muscle', Icons.fitness_center, Colors.blueAccent),
      ('Improve Endurance', Icons.directions_run, Colors.orange),
      ('Maintain Fitness', Icons.balance, Colors.green),
      ('Improve Flexibility', Icons.self_improvement, Colors.purple),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: goals.map((goal) {
        final selected = profile.goal == goal.$1;
        return GestureDetector(
          onTap: () => context.read<ProfileProvider>().updateGoal(goal.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? goal.$3.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? goal.$3 : Colors.black12, width: selected ? 1.5 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(goal.$2, color: selected ? goal.$3 : Colors.black38, size: 16),
                const SizedBox(width: 6),
                Text(goal.$1, style: TextStyle(color: selected ? goal.$3 : Colors.black54, fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssessmentResult(ProfileProvider profile, Color bmiColor) {
    String interpretation;
    String suggestion;

    if (profile.bmi < 18.5) {
      interpretation = 'Your BMI suggests you may be underweight. Focus on building healthy mass through nutrition and strength training.';
      suggestion = 'Prioritize strength training with nutrient-dense meals.';
    } else if (profile.bmi < 25.0) {
      interpretation = 'Your BMI is in the normal range. Maintain your current routine for balanced health and performance.';
      suggestion = 'A balanced mix of all four workout categories will keep you in strong shape.';
    } else if (profile.bmi < 30.0) {
      interpretation = 'Your BMI is slightly above normal. A combination of cardio and strength training can help.';
      suggestion = 'Prioritize cardio and HIIT while keeping strength work in place to preserve muscle.';
    } else {
      interpretation = 'Your BMI is in a higher-risk range. Start with low-impact exercise and consider medical guidance if needed.';
      suggestion = 'Begin with flexibility and light cardio, then gradually increase intensity.';
    }

    return _card(
      color: bmiColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _glowBadge('BMI: ${profile.bmi.toStringAsFixed(1)}', bmiColor),
              const SizedBox(width: 10),
              _glowBadge(profile.bmiCategoryLabel, bmiColor, small: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(interpretation, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_outlined, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(suggestion, style: const TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic, height: 1.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(ProfileProvider profile) {
    final items = _recommendations(profile.goal);
    return Column(
      children: items.map((item) {
        final color = item['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(item['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['category'] as String, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${item['frequency']}x/week | ${item['duration']} | ${item['intensity']}', style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(item['intensity'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _recommendations(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return [
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 3, 'duration': '30 min', 'intensity': 'High'},
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 4, 'duration': '40 min', 'intensity': 'Moderate'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '45 min', 'intensity': 'Moderate'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.green, 'frequency': 2, 'duration': '20 min', 'intensity': 'Low'},
        ];
      case 'Build Muscle':
        return [
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 4, 'duration': '60 min', 'intensity': 'High'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 2, 'duration': '20 min', 'intensity': 'High'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.green, 'frequency': 3, 'duration': '20 min', 'intensity': 'Low'},
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 1, 'duration': '30 min', 'intensity': 'Light'},
        ];
      case 'Improve Endurance':
        return [
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 5, 'duration': '45 min', 'intensity': 'Moderate'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 2, 'duration': '30 min', 'intensity': 'High'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '40 min', 'intensity': 'Moderate'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.green, 'frequency': 2, 'duration': '20 min', 'intensity': 'Low'},
        ];
      case 'Improve Flexibility':
        return [
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.green, 'frequency': 5, 'duration': '30 min', 'intensity': 'Low'},
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 3, 'duration': '30 min', 'intensity': 'Light'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '40 min', 'intensity': 'Moderate'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 1, 'duration': '20 min', 'intensity': 'Moderate'},
        ];
      default:
        return [
          {'category': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.pinkAccent, 'frequency': 3, 'duration': '30 min', 'intensity': 'Moderate'},
          {'category': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueAccent, 'frequency': 2, 'duration': '45 min', 'intensity': 'Moderate'},
          {'category': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.orangeAccent, 'frequency': 2, 'duration': '25 min', 'intensity': 'Moderate'},
          {'category': 'Flexibility', 'icon': Icons.self_improvement, 'color': Colors.green, 'frequency': 2, 'duration': '20 min', 'intensity': 'Low'},
        ];
    }
  }

  Widget _buildProgressTracking(
    ProfileProvider profile,
    RoutineProvider routine,
  ) {
    final weightChange = profile.weightChangeKg;
    final completionColor = routine.isRoutineComplete
        ? Colors.green
        : Colors.pinkAccent;
    return _card(
      color: Colors.pinkAccent,
      child: Column(
        children: [
          Row(
            children: [
              MetricCard(label: 'Initial Weight', value: profile.formatWeight(profile.initialWeightKg), sub: 'baseline', color: Colors.blueAccent),
              const SizedBox(width: 8),
              MetricCard(label: 'Current Weight', value: profile.formatWeight(profile.weightKg), sub: 'recorded', color: Colors.green),
              const SizedBox(width: 8),
              MetricCard(label: 'Change', value: '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg', sub: 'actual', color: weightChange <= 0 ? Colors.green : Colors.orange),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              MetricCard(label: 'Calories Burned', value: '${_caloriesBurned.toInt()} kcal', sub: 'estimated', color: Colors.orange),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Routine Done',
                value: '${routine.completedExerciseCount}/${routine.exerciseCount}',
                sub: routine.hasRoutine ? 'checked complete' : 'no routine yet',
                color: completionColor,
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Workout Completion', style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(
                '${(routine.completionProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: completionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: routine.completionProgress,
              backgroundColor: completionColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(completionColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            routine.hasRoutine
                ? routine.isRoutineComplete
                    ? '* All exercises in your current routine are marked complete.'
                    : '* Tick exercises complete in Routine Summary to update this progress bar.'
                : '* Add exercises to your routine to start tracking workout completion.',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.35),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          if (routine.hasRoutine)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${routine.remainingExerciseCount} exercise(s) remaining in your routine.',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferences(ProfileProvider profile) {
    return _card(
      color: Colors.teal,
      child: Column(
        children: [
          _InputRow(label: 'Weight Unit', value: profile.weightUnit.toUpperCase(), icon: Icons.straighten, color: Colors.teal, onEdit: () => _editPicker('Weight Unit', const ['kg', 'lbs'], profile.weightUnit, (value) => context.read<ProfileProvider>().saveWeightUnit(value))),
          _divider(),
          _InputRow(label: 'Rest Timer', value: '${profile.restTimer} sec', icon: Icons.timer_outlined, color: Colors.teal, onEdit: () => _editSlider('Rest Timer', profile.restTimer.toDouble(), 15, 300, divisions: 19, valueTextBuilder: (value) => '${value.toInt()} sec', onSave: (value) => context.read<ProfileProvider>().saveRestTimer(value.toInt()))),
          _divider(),
          _PreferenceSwitchRow(
            label: 'Notifications',
            description: 'Workout reminders and profile alerts',
            value: profile.notificationsEnabled,
            color: Colors.teal,
            onChanged: (value) => context.read<ProfileProvider>().toggleNotifications(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProfileProvider profile) {
    return Column(
      children: [
        _ActionButton(
          label: 'CHANGES SAVE AUTOMATICALLY',
          icon: Icons.cloud_done_outlined,
          color: Colors.blueAccent,
          onTap: () => _snack('Profile settings are saved automatically.', Colors.blueAccent),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'UPDATE WEIGHT WEEKLY CHECK-IN',
          icon: Icons.monitor_weight_outlined,
          color: Colors.green,
          onTap: () => _editSlider('Update Current Weight (kg)', profile.weightKg, 30, 200, onSave: (value) => context.read<ProfileProvider>().updateWeightKg(value)),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'RESET PROFILE DATA',
          icon: Icons.restart_alt,
          color: Colors.orange,
          onTap: () async {
            final confirmed = await _confirmAction('Reset Profile Data', 'This will restore your profile fields to their default values. Preferences will stay as they are.');
            if (!mounted || !confirmed) {
              return;
            }
            await context.read<ProfileProvider>().resetProfile();
            if (!mounted) {
              return;
            }
            _snack('Profile data reset.', Colors.orange);
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'RESET ALL SETTINGS',
          icon: Icons.delete_sweep_outlined,
          color: Colors.redAccent,
          onTap: () async {
            final confirmed = await _confirmAction('Reset Everything', 'This will reset your profile details and preferences back to the app defaults.');
            if (!mounted || !confirmed) {
              return;
            }
            await context.read<ProfileProvider>().resetAll();
            if (!mounted) {
              return;
            }
            _snack('Profile and preferences reset.', Colors.redAccent);
          },
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(AuthProvider auth) async {
    final confirmed = await _confirmAction(
      'Sign out?',
      'You will need to sign in again to access your dashboard.',
    );
    if (!mounted || !confirmed) {
      return;
    }
    await auth.logout();
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25.0) return Colors.green;
    if (bmi < 30.0) return Colors.orange;
    return Colors.redAccent;
  }

  Widget _card({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 1)],
      ),
      child: child,
    );
  }

  Widget _badge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _glowBadge(String text, Color color, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16, vertical: small ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: small ? 14 : 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(width: 3, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
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
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(expanded ? 'Minimize' : 'Expand', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: color, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        expanded ? child : Text('$title hidden', style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }

  Widget _divider() => Divider(color: Colors.black.withValues(alpha: 0.06), height: 1);

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editText(String label, String initial, ValueChanged<String> onSave) async {
    final controller = TextEditingController(text: initial);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { onSave(controller.text.trim()); Navigator.pop(context); }, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _editSlider(
    String label,
    double initial,
    double min,
    double max, {
    int? divisions,
    String Function(double value)? valueTextBuilder,
    required ValueChanged<double> onSave,
  }) async {
    double current = initial.clamp(min, max).toDouble();
    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(valueTextBuilder?.call(current) ?? current.toInt().toString(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              Slider(value: current, min: min, max: max, divisions: divisions, onChanged: (value) => setStateDialog(() => current = value)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () { onSave(current); Navigator.pop(context); }, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Future<void> _editPicker(String label, List<String> options, String current, ValueChanged<String> onSave) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              trailing: option == current ? const Icon(Icons.check, color: Colors.blueAccent) : null,
              onTap: () { onSave(option); Navigator.pop(context); },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool> _confirmAction(String title, String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
    return confirmed ?? false;
  }

  String _formatDateTime(DateTime value) {
    final month = switch (value.month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      _ => 'Dec',
    };
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month ${value.day}, ${value.year} at $hour:$minute';
  }
}

class _InputRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onEdit;

  const _InputRow({required this.label, required this.value, required this.icon, required this.color, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isReadOnly = onEdit == _noopEdit;
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
                Text(label, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          InkWell(
            onTap: isReadOnly ? null : onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isReadOnly ? 0.04 : 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: isReadOnly ? 0.2 : 0.45),
                ),
              ),
              child: Text(
                isReadOnly ? 'View' : 'Edit',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _noopEdit() {}

class _PreferenceSwitchRow extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _PreferenceSwitchRow({required this.label, required this.description, required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.notifications_outlined, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(color: Colors.black45, fontSize: 11)),
            ],
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color, width: 1.5),
          boxShadow: [BoxShadow(color: widget.color.withValues(alpha: _pressed ? 0.45 : 0.18), blurRadius: _pressed ? 18 : 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 18),
            const SizedBox(width: 10),
            Text(widget.label, style: TextStyle(color: widget.color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }
}


