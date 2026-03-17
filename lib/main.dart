import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo.shade900),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String getFitnessNote() {
    String? optionalNote;
    return optionalNote ?? "No fitness note available";
  }

  Future<String> fetchWorkoutOfTheDay() async {
    return Future.delayed(
      const Duration(seconds: 2),
          () => "Today's workout: Push-ups & Squats",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ---
      appBar: AppBar(
        title: const Text('My Fitness Tracker'),
        leading: const Icon(Icons.fitness_center),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),

      // --- BODY ---
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Null safety example
          Text(
            getFitnessNote(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Async Future example with FutureBuilder
          FutureBuilder<String>(
            future: fetchWorkoutOfTheDay(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text("Error loading workout");
              } else {
                return Text(
                  snapshot.data ?? "",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              }
            },
          ),
        ],
      ),

      // --- FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Later: Add new workout entry
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}