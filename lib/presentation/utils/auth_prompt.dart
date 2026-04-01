import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

Future<void> openLoginScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
    ),
  );
}

Future<void> showSignInRequiredDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Sign in required'),
        content: const Text(
          'Sign in to unlock routines, workout tracking, profile tools, and saved progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openLoginScreen(context);
            },
            child: const Text('Sign In'),
          ),
        ],
      );
    },
  );
}
