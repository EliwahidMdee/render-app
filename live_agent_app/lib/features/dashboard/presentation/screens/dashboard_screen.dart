import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/user_profile_header.dart';
import '../../../sessions/presentation/providers/sessions_provider.dart';
import '../../../sessions/presentation/screens/sessions_list_screen.dart';
import '../widgets/dashboard_stat_card.dart';

enum DateFilter { today, lastWeek, thisMonth, thisYear, all }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateFilter _selectedFilter = DateFilter.all;

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(sessionsProvider);
    final authState = ref.watch(authProvider);

    // Filter sessions based on date range
    final filteredSessions = _filterSessionsByDate(
      sessionsState.sessions,
      _selectedFilter,
    );

    // Count sessions by status
    final pendingSessions = filteredSessions
        .where((s) => s.status == AppConstants.statusPending)
        .length;
    final activeSessions = filteredSessions
        .where((s) => s.status == AppConstants.statusActive)
        .length;
    final resolvedSessions = filteredSessions
        .where((s) => s.status == AppConstants.statusResolved)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: UserProfileHeader(
          agent: authState.agent,
          onSettingsTap: () {
            // TODO: Navigate to settings screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings screen - Coming soon')),
            );
          },
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(sessionsProvider.notifier).refreshSessions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Title
                Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Overview of your sessions',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Date Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', DateFilter.all),
                      const SizedBox(width: 8),
                      _buildFilterChip('Today', DateFilter.today),
                      const SizedBox(width: 8),
                      _buildFilterChip('Last Week', DateFilter.lastWeek),
                      const SizedBox(width: 8),
                      _buildFilterChip('This Month', DateFilter.thisMonth),
                      const SizedBox(width: 8),
                      _buildFilterChip('This Year', DateFilter.thisYear),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                DashboardStatCard(
                  title: 'Pending Sessions',
                  count: pendingSessions,
                  icon: Icons.pending_outlined,
                  color: AppColors.statusPending,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SessionsListScreen(
                          initialFilter: AppConstants.statusPending,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                DashboardStatCard(
                  title: 'Active Sessions',
                  count: activeSessions,
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.statusActive,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SessionsListScreen(
                          initialFilter: AppConstants.statusActive,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                DashboardStatCard(
                  title: 'Resolved Sessions',
                  count: resolvedSessions,
                  icon: Icons.check_circle_outline,
                  color: AppColors.statusResolved,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SessionsListScreen(
                          initialFilter: AppConstants.statusResolved,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SessionsListScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('All Sessions'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(sessionsProvider.notifier).refreshSessions();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, DateFilter filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: GoogleFonts.roboto(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  List<dynamic> _filterSessionsByDate(List<dynamic> sessions, DateFilter filter) {
    final now = DateTime.now();
    
    switch (filter) {
      case DateFilter.today:
        return sessions.where((s) {
          final sessionDate = s.createdAt;
          return sessionDate.year == now.year &&
              sessionDate.month == now.month &&
              sessionDate.day == now.day;
        }).toList();
      
      case DateFilter.lastWeek:
        final lastWeek = now.subtract(const Duration(days: 7));
        return sessions.where((s) {
          return s.createdAt.isAfter(lastWeek);
        }).toList();
      
      case DateFilter.thisMonth:
        return sessions.where((s) {
          final sessionDate = s.createdAt;
          return sessionDate.year == now.year &&
              sessionDate.month == now.month;
        }).toList();
      
      case DateFilter.thisYear:
        return sessions.where((s) {
          return s.createdAt.year == now.year;
        }).toList();
      
      case DateFilter.all:
      default:
        return sessions;
    }
  }
}
