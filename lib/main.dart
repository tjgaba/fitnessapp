import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/profile_repository.dart';
import 'data/routine_repository.dart';
import 'domain/profile_provider.dart';
import 'domain/routine_provider.dart';
import 'presentation/tabs/homescreen.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProfileRepository>(create: (_) => ProfileRepository()),
        Provider<RoutineRepository>(create: (_) => RoutineRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              ProfileProvider(context.read<ProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RoutineProvider(context.read<RoutineRepository>()),
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
        home: const HomeScreen(),
      ),
    );
  }
}
