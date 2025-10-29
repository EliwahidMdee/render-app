import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isAgent = message.isFromAgent;
    // REVERSED: agent messages on right (like user sent them), user messages on left (like agent sent them)
    final alignment = isAgent ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isAgent
        ? AppColors.userMessageBubble  // Agent messages use user bubble color (green)
        : AppColors.agentMessageBubble; // User messages use agent bubble color (white)
    
    // Check if message is pending
    final isPending = message.metadata?['isPending'] == true;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isAgent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender Name (for user messages only - REVERSED)
            if (!isAgent)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      message.senderName,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Message Bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                border: !isAgent  // REVERSED: user messages now have border
                    ? Border.all(color: Colors.grey.shade300, width: 1)
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAgent ? 16 : 4),  // REVERSED
                  bottomRight: Radius.circular(isAgent ? 4 : 16), // REVERSED
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message Text
                  Text(
                    message.messageText,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Timestamp and Read Status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(
                          message.createdAt.isUtc 
                            ? message.createdAt.toLocal() 
                            : message.createdAt
                        ),
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // REVERSED: Show clock icon for pending user messages
                      if (!isAgent && isPending) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                      // REVERSED: Show ticks for agent messages (they appear as if agent sent them)
                      if (isAgent && !isPending) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.readByAgent
                              ? Icons.done_all  // Double tick (read)
                              : Icons.done_all,  // Double tick (delivered)
                          size: 14,
                          color: message.readByAgent
                              ? Colors.blue  // Blue for read
                              : Colors.grey,  // Grey for delivered
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
