import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/agent_model.dart';

class UserProfileHeader extends StatelessWidget {
  final AgentModel? agent;
  final VoidCallback? onSettingsTap;

  const UserProfileHeader({
    super.key,
    this.agent,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    if (agent == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Text(
              agent!.name.isNotEmpty ? agent!.name[0].toUpperCase() : 'A',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  agent!.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  agent!.email,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: onSettingsTap,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
