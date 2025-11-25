import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Home screen - displayed after successful authentication
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Helper method to safely get the initial from user's display name or email
  String _getInitial(user) {
    if (user == null) return 'U';

    // Try to get initial from display name
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!.substring(0, 1).toUpperCase();
    }

    // Try to get initial from email
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.substring(0, 1).toUpperCase();
    }

    // Default fallback
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BlazePlayer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Picture
              if (user?.photoURL != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user!.photoURL!),
                )
              else
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    _getInitial(user),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Welcome Message
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // User Info
              if (user?.displayName != null)
                Text(
                  user!.displayName!,
                  style: TextStyle(fontSize: 20, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 4),

              if (user?.email != null)
                Text(
                  user!.email!,
                  style: TextStyle(fontSize: 16, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 40),

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication Successful!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Firebase authentication is working perfectly. You can now build your app features.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
