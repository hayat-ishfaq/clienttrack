import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

enum InvoiceStatusType {
  paid,
  overdue,
  dueSoon,
  dueToday,
  sent,
  shared,
  draft,
}

enum ClientReliabilityType {
  reliable,
  sometimesLate,
  chronicallyLate,
}

/// Status chip with pill shaping and semantic colors.
class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusChip.fromInvoiceStatus(InvoiceStatusType status) {
    switch (status) {
      case InvoiceStatusType.paid:
        return const StatusChip(
          label: 'Paid',
          backgroundColor: AppColors.paidTealBg,
          textColor: AppColors.paidTeal,
          icon: Icons.check_circle_outline,
        );
      case InvoiceStatusType.overdue:
        return const StatusChip(
          label: 'Overdue',
          backgroundColor: AppColors.overdueRedBg,
          textColor: AppColors.overdueRed,
          icon: Icons.error_outline,
        );
      case InvoiceStatusType.dueSoon:
        return const StatusChip(
          label: 'Due Soon',
          backgroundColor: AppColors.dueSoonAmberBg,
          textColor: AppColors.dueSoonAmber,
          icon: Icons.access_time,
        );
      case InvoiceStatusType.dueToday:
        return const StatusChip(
          label: 'Due Today',
          backgroundColor: AppColors.dueSoonAmberBg,
          textColor: AppColors.dueSoonAmber,
          icon: Icons.warning_amber_rounded,
        );
      case InvoiceStatusType.sent:
      case InvoiceStatusType.shared:
        return const StatusChip(
          label: 'Shared',
          backgroundColor: AppColors.sentBlueBg,
          textColor: AppColors.sentBlue,
          icon: Icons.send_outlined,
        );
      case InvoiceStatusType.draft:
        return const StatusChip(
          label: 'Draft',
          backgroundColor: AppColors.draftGreyBg,
          textColor: AppColors.draftGrey,
          icon: Icons.edit_note,
        );
    }
  }

  factory StatusChip.fromReliability(ClientReliabilityType reliability) {
    switch (reliability) {
      case ClientReliabilityType.reliable:
        return const StatusChip(
          label: 'Reliable',
          backgroundColor: AppColors.paidTealBg,
          textColor: AppColors.paidTeal,
          icon: Icons.verified_outlined,
        );
      case ClientReliabilityType.sometimesLate:
        return const StatusChip(
          label: 'Sometimes Late',
          backgroundColor: AppColors.dueSoonAmberBg,
          textColor: AppColors.dueSoonAmber,
          icon: Icons.schedule,
        );
      case ClientReliabilityType.chronicallyLate:
        return const StatusChip(
          label: 'Chronically Late',
          backgroundColor: AppColors.overdueRedBg,
          textColor: AppColors.overdueRed,
          icon: Icons.warning_amber_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
