import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/user_profile_header.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/sessions_provider.dart';
import '../widgets/session_card.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SessionsListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  
  const SessionsListScreen({
    super.key,
    this.initialFilter,
  });

  @override
  ConsumerState<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends ConsumerState<SessionsListScreen> {
  String? _selectedStatus;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilter;
    if (_selectedStatus != null) {
      // Apply filter after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionsProvider.notifier).filterByStatus(_selectedStatus);
      });
    }
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Auto-refresh sessions every 3 seconds (user requested at least 3s)
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        ref.read(sessionsProvider.notifier).refreshSessions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(sessionsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: UserProfileHeader(
          agent: authState.agent,
          onSettingsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        leading: widget.initialFilter != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: widget.initialFilter != null,
        toolbarHeight: 80,
        actions: [
          // Dashboard button (only if not from dashboard filter)
          if (widget.initialFilter == null)
            IconButton(
              icon: const Icon(Icons.dashboard),
              tooltip: 'Dashboard',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          // Refresh
          IconButton(
            icon: sessionsState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: sessionsState.isLoading
                ? null
                : () {
                    ref.read(sessionsProvider.notifier).refreshSessions();
                  },
            tooltip: sessionsState.isLoading ? 'Refreshing...' : 'Refresh',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              }
            },
          ),
        ],
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
      body: sessionsState.isLoading && sessionsState.sessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : sessionsState.error != null && sessionsState.sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading sessions',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sessionsState.error!,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(sessionsProvider.notifier).refreshSessions();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : sessionsState.sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sessions found',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new requests',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(sessionsProvider.notifier).refreshSessions();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: sessionsState.sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessionsState.sessions[index];
                          return SessionCard(
                            session: session,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    session: session,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
