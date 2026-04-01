import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/auth_provider.dart';
import 'app_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        if (snapshot.hasData) {
          return _AuthenticatedSessionGuard(userKey: snapshot.data?.uid ?? '');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        });

        return const AppRouter();
      },
    );
  }
}

class _AuthenticatedSessionGuard extends StatefulWidget {
  const _AuthenticatedSessionGuard({required this.userKey});

  final String userKey;

  @override
  State<_AuthenticatedSessionGuard> createState() =>
      _AuthenticatedSessionGuardState();
}

class _AuthenticatedSessionGuardState extends State<_AuthenticatedSessionGuard> {
  late Future<bool> _validationFuture;

  @override
  void initState() {
    super.initState();
    _validationFuture = context.read<AuthProvider>().validatePersistedSession();
  }

  @override
  void didUpdateWidget(covariant _AuthenticatedSessionGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userKey != widget.userKey) {
      _validationFuture =
          context.read<AuthProvider>().validatePersistedSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _validationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AuthLoadingScreen();
        }

        final message =
            context.read<AuthProvider>().consumeSessionExpiredMessage();
        if (message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }

        if (snapshot.data == false) {
          return const AppRouter();
        }

        return const AppRouter();
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
