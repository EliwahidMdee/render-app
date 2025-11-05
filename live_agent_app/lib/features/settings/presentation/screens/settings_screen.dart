import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'package:live_agent_app/features/core/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'Last updated: ${DateTime.now().year}\n\n'
            'We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our Live Agent application.\n\n'
            '1. Information Collection\n'
            '   - We collect information you provide during registration\n'
            '   - Chat messages and session data\n'
            '   - Device information for notifications\n\n'
            '2. Information Use\n'
            '   - To provide customer support services\n'
            '   - To improve our application\n'
            '   - To send notifications about new messages\n\n'
            '3. Data Security\n'
            '   - We use industry-standard encryption\n'
            '   - Secure authentication with JWT tokens\n'
            '   - Regular security audits\n\n'
            '4. Your Rights\n'
            '   - Access your personal data\n'
            '   - Request data deletion\n'
            '   - Opt-out of notifications\n\n'
            'For more information, please contact your system administrator.',
            style: GoogleFonts.roboto(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog() {
    final authState = ref.read(authProvider);
    final nameController = TextEditingController(
      text: authState.agent?.name ?? '',
    );
    final emailController = TextEditingController(
      text: authState.agent?.email ?? '',
    );
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'New password (optional)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Min length: 8 characters',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, dialogRef, _) {
              final isLoading = dialogRef.watch(authProvider).isLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final newName = nameController.text.trim();
                        final newEmail = emailController.text.trim();
                        final newPassword = passwordController.text;

                        // Basic validation
                        if (newEmail.isNotEmpty && !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(newEmail)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email')),
                          );
                          return;
                        }

                        if (newPassword.isNotEmpty && newPassword.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 8 characters')),
                          );
                          return;
                        }

                        final currentEmail = authState.agent?.email ?? '';
                        final willChangeEmail = newEmail.isNotEmpty && newEmail != currentEmail;

                        try {
                          await ref.read(authProvider.notifier).updateProfile(
                                fullName: newName.isEmpty ? null : newName,
                                email: newEmail.isEmpty ? null : newEmail,
                                password: newPassword.isEmpty ? null : newPassword,
                              );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Profile updated successfully')),
                            );

                            if (willChangeEmail) {
                              // Inform the user they need to re-login to get a token with updated email
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Re-login required'),
                                  content: const Text('You changed your email. Please log out and log in again to refresh your session token.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Update failed: $e')),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          Text(
            'Account',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (() {
                        final name = authState.agent?.name ?? '';
                        final trimmed = name.trim();
                        if (trimmed.isEmpty) return 'A';
                        return trimmed.characters.first.toUpperCase();
                      })(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    authState.agent?.name ?? 'Agent',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    authState.agent?.email ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _showEditAccountDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Session Section
          Text(
            'Session',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          Text(
            'Appearance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref2, _) {
              final themeMode = ref2.watch(themeNotifierProvider);
              final isDark = themeMode == ThemeMode.dark;
              return Card(
                child: SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? 'Enabled' : 'Disabled',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: isDark,
                  onChanged: (value) async {
                    await ref.read(themeNotifierProvider.notifier).setDarkMode(value);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Legal Section
          Text(
            'Legal',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPrivacyPolicy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          Text(
            'About',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'Version',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    AppConstants.appVersion,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.apps_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'App Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    AppConstants.appName,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
