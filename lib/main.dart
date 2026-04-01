import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'data/repositories/profile_repository.dart';
import 'data/repositories/routine_repository.dart';
import 'data/repositories/exercise_api_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/location_service.dart';
import 'data/services/notification_service.dart';
import 'domain/providers/auth_provider.dart';
import 'domain/providers/exercise_search_provider.dart';
import 'domain/providers/profile_provider.dart';
import 'domain/providers/routine_provider.dart';
import 'domain/providers/workout_tracking_provider.dart';
import 'firebase_options.dart';
import 'presentation/navigation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final notificationService = NotificationService();
    await notificationService.init();

    runApp(FitnessApp(notificationService: notificationService));
  } catch (error, stackTrace) {
    debugPrint('Startup error: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(
      StartupFailureApp(
        message: error.toString(),
      ),
    );
  }
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({
    required this.notificationService,
    super.key,
  });

  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProfileRepository>(create: (_) => ProfileRepository()),
        Provider<RoutineRepository>(create: (_) => RoutineRepository()),
        Provider<ExerciseApiRepository>(create: (_) => ExerciseApiRepository()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ProfileProvider(
                context.read<ProfileRepository>(),
                context.read<AuthService>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RoutineProvider(context.read<RoutineRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ExerciseSearchProvider(
            context.read<ExerciseApiRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkoutTrackingProvider(
            context.read<LocationService>(),
            context.read<NotificationService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Fitness App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Startup failed',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
