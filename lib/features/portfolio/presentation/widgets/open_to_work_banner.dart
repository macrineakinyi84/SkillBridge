import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

enum OpenToWorkStatus {
  openToAll,
  internshipsOnly,
  notLooking,
}

class OpenToWorkBanner extends StatelessWidget {
  const OpenToWorkBanner({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  final OpenToWorkStatus status;
  final ValueChanged<OpenToWorkStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isOpen = status != OpenToWorkStatus.notLooking;
    final ringColor = isOpen ? AppColors.success : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 3),
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.background,
                child: Icon(Icons.person_rounded, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleFor(status),
                  style: AppTypography.body(context, isDark: false),
                ),
                const SizedBox(height: 2),
                Text(
                  'Visible to employers in search results.',
                  style: AppTypography.caption(context, isDark: false),
                ),
              ],
            ),
          ),
          PopupMenuButton<OpenToWorkStatus>(
            onSelected: onStatusChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: OpenToWorkStatus.openToAll,
                child: Text('Open to All'),
              ),
              const PopupMenuItem(
                value: OpenToWorkStatus.internshipsOnly,
                child: Text('Internships Only'),
              ),
              const PopupMenuItem(
                value: OpenToWorkStatus.notLooking,
                child: Text('Not Looking'),
              ),
            ],
            child: Row(
              children: const [
                Text('Status'),
                Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(OpenToWorkStatus status) {
    switch (status) {
      case OpenToWorkStatus.openToAll:
        return 'Open to work';
      case OpenToWorkStatus.internshipsOnly:
        return 'Open to internships only';
      case OpenToWorkStatus.notLooking:
        return 'Not currently looking';
    }
  }
}

