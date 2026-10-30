import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../features/clients/data/client_repository.dart';
import '../../features/clients/domain/models/client_model.dart';
import '../../features/invoices/data/invoice_repository.dart';
import '../../features/invoices/domain/models/invoice_model.dart';
import '../../features/projects/data/project_repository.dart';
import '../../features/projects/domain/models/project_model.dart';

// =============================================================================
// 1. DASHBOARD METRICS AGGREGATOR
// =============================================================================

@immutable
class DashboardMetrics {
  final double totalOutstanding;
  final double earnedThisMonth;
  final double overdueTotal;
  final int overdueInvoicesCount;
  final int openInvoicesCount;
  final int totalInvoicesCount;
  final int activeProjectsCount;
  final int totalProjectsCount;
  final int totalClientsCount;
  final List<ProjectModel> upcomingDeadlines;
  final List<InvoiceModel> recentInvoices;

  const DashboardMetrics({
    required this.totalOutstanding,
    required this.earnedThisMonth,
    required this.overdueTotal,
    required this.overdueInvoicesCount,
    required this.openInvoicesCount,
    required this.totalInvoicesCount,
    required this.activeProjectsCount,
    required this.totalProjectsCount,
    required this.totalClientsCount,
    required this.upcomingDeadlines,
    required this.recentInvoices,
  });

  bool get hasOverdueInvoices => overdueInvoicesCount > 0;
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final invoices = ref.watch(invoicesStreamProvider).asData?.value ?? kSeedInvoices;
  final projects = ref.watch(projectsStreamProvider).asData?.value ?? kSeedProjects;
  final clients = ref.watch(clientsStreamProvider).asData?.value ?? kSeedClients;

  final now = DateTime.now();

  // Invoices segregation
  final openInvoices = invoices.where((i) => i.status != InvoiceStatus.paid).toList();
  final overdueInvoices = invoices.where((i) => i.isOverdue || i.status == InvoiceStatus.overdue).toList();
  final paidInvoices = invoices.where((i) => i.status == InvoiceStatus.paid).toList();

  final totalOutstanding = openInvoices.fold<double>(0.0, (sum, i) => sum + i.balanceDue);
  final overdueTotal = overdueInvoices.fold<double>(0.0, (sum, i) => sum + i.balanceDue);

  // Invoices paid in current month
  final earnedThisMonth = paidInvoices.where((i) {
    return i.paidAt != null &&
        i.paidAt!.month == now.month &&
        i.paidAt!.year == now.year;
  }).fold<double>(0.0, (sum, i) => sum + i.totalAmount);

  // Projects segregation
  final activeProjects = projects.where((p) => p.status != ProjectStatus.completed).toList();

  // Upcoming deadlines (nearest deadline first)
  final projectsWithDeadlines = projects.where((p) => p.deadline != null).toList()
    ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  final upcomingDeadlines = (projectsWithDeadlines.isNotEmpty ? projectsWithDeadlines : projects)
      .take(4)
      .toList();

  // Recent invoices (newest first)
  final sortedInvoices = [...invoices]..sort((a, b) => b.issueDate.compareTo(a.issueDate));
  final recentInvoices = sortedInvoices.take(3).toList();

  return DashboardMetrics(
    totalOutstanding: totalOutstanding,
    earnedThisMonth: earnedThisMonth,
    overdueTotal: overdueTotal,
    overdueInvoicesCount: overdueInvoices.length,
    openInvoicesCount: openInvoices.length,
    totalInvoicesCount: invoices.length,
    activeProjectsCount: activeProjects.length,
    totalProjectsCount: projects.length,
    totalClientsCount: clients.length,
    upcomingDeadlines: upcomingDeadlines,
    recentInvoices: recentInvoices,
  );
});

// =============================================================================
// 2. CLIENT RELIABILITY & PAYMENT HISTORY AGGREGATOR
// =============================================================================

enum ReliabilityTier {
  reliable,
  sometimesLate,
  chronicallyLate,
  unrated,
}

@immutable
class ClientReliabilitySummary {
  final double totalBilled;
  final double totalPaid;
  final double outstanding;
  final int totalInvoices;
  final int paidInvoicesCount;
  final int overdueInvoicesCount;
  final int avgDaysLate;
  final int onTimePercent;
  final ReliabilityTier tier;
  final String tierLabel;
  final Color tierBgColor;
  final Color tierFgColor;

  const ClientReliabilitySummary({
    required this.totalBilled,
    required this.totalPaid,
    required this.outstanding,
    required this.totalInvoices,
    required this.paidInvoicesCount,
    required this.overdueInvoicesCount,
    required this.avgDaysLate,
    required this.onTimePercent,
    required this.tier,
    required this.tierLabel,
    required this.tierBgColor,
    required this.tierFgColor,
  });
}

final clientPaymentSummaryProvider =
    Provider.family<ClientReliabilitySummary, String>((ref, clientId) {
  final invoices = ref.watch(clientInvoicesStreamProvider(clientId)).asData?.value ?? [];

  final billed = invoices.fold<double>(0.0, (s, i) => s + i.totalAmount);
  final paid = invoices.fold<double>(0.0, (s, i) => s + i.amountPaid);
  final outstanding = (billed - paid).clamp(0.0, double.infinity);

  if (invoices.isEmpty) {
    return const ClientReliabilitySummary(
      totalBilled: 0.0,
      totalPaid: 0.0,
      outstanding: 0.0,
      totalInvoices: 0,
      paidInvoicesCount: 0,
      overdueInvoicesCount: 0,
      avgDaysLate: 0,
      onTimePercent: 100,
      tier: ReliabilityTier.unrated,
      tierLabel: 'New Client',
      tierBgColor: AppColors.draftGreyBg,
      tierFgColor: AppColors.draftGrey,
    );
  }

  int totalLateDays = 0;
  int onTimeCount = 0;
  int overdueCount = 0;
  int paidCount = 0;

  for (final inv in invoices) {
    if (inv.status == InvoiceStatus.paid) {
      paidCount++;
      if (inv.paidAt != null && inv.paidAt!.isAfter(inv.dueDate)) {
        final days = inv.paidAt!.difference(inv.dueDate).inDays;
        totalLateDays += days;
      } else {
        onTimeCount++;
      }
    } else if (inv.isOverdue || inv.status == InvoiceStatus.overdue) {
      overdueCount++;
      totalLateDays += inv.daysOverdue;
    }
  }

  final avgDaysLate = invoices.isNotEmpty ? (totalLateDays / invoices.length).round() : 0;
  final onTimePercent = invoices.isNotEmpty ? ((onTimeCount / invoices.length) * 100).round() : 100;

  ReliabilityTier tier;
  String tierLabel;
  Color chipBg;
  Color chipFg;

  if (onTimePercent >= 85 && avgDaysLate <= 1) {
    tier = ReliabilityTier.reliable;
    tierLabel = 'Reliable';
    chipBg = AppColors.paidTealBg;
    chipFg = AppColors.paidTeal;
  } else if (onTimePercent >= 50 && avgDaysLate <= 7) {
    tier = ReliabilityTier.sometimesLate;
    tierLabel = 'Sometimes Late';
    chipBg = AppColors.dueSoonAmberBg;
    chipFg = AppColors.dueSoonAmber;
  } else {
    tier = ReliabilityTier.chronicallyLate;
    tierLabel = 'Chronically Late';
    chipBg = AppColors.overdueRedBg;
    chipFg = AppColors.overdueRed;
  }

  return ClientReliabilitySummary(
    totalBilled: billed,
    totalPaid: paid,
    outstanding: outstanding,
    totalInvoices: invoices.length,
    paidInvoicesCount: paidCount,
    overdueInvoicesCount: overdueCount,
    avgDaysLate: avgDaysLate,
    onTimePercent: onTimePercent,
    tier: tier,
    tierLabel: tierLabel,
    tierBgColor: chipBg,
    tierFgColor: chipFg,
  );
});

// ── FT-031: Late-Payer Risk Model & Aggregator ─────────────────────────────

@immutable
class LatePayerRisk {
  final ClientModel client;
  final int overdueInvoicesCount;
  final double totalOverdueAmount;
  final int avgDaysLate;

  const LatePayerRisk({
    required this.client,
    required this.overdueInvoicesCount,
    required this.totalOverdueAmount,
    required this.avgDaysLate,
  });
}

/// Surfaces clients classified as Chronically Late who have pending overdue invoices.
final latePayerRisksProvider = Provider<List<LatePayerRisk>>((ref) {
  final clients = ref.watch(clientsStreamProvider).asData?.value ?? kSeedClients;
  final invoices = ref.watch(invoicesStreamProvider).asData?.value ?? kSeedInvoices;

  final List<LatePayerRisk> risks = [];

  for (final client in clients) {
    final clientInvoices = invoices.where((i) => i.clientId == client.id).toList();
    if (clientInvoices.isEmpty) continue;

    final summary = ref.watch(clientPaymentSummaryProvider(client.id));
    if (summary.tier == ReliabilityTier.chronicallyLate && summary.overdueInvoicesCount > 0) {
      risks.add(LatePayerRisk(
        client: client,
        overdueInvoicesCount: summary.overdueInvoicesCount,
        totalOverdueAmount: summary.outstanding,
        avgDaysLate: summary.avgDaysLate,
      ));
    }
  }

  risks.sort((a, b) => b.totalOverdueAmount.compareTo(a.totalOverdueAmount));
  return risks;
});

// =============================================================================
// 3. PROJECT FINANCIAL & STATUS SUMMARY AGGREGATOR
// =============================================================================

@immutable
class ProjectFinancialSummary {
  final double budget;
  final double totalInvoiced;
  final double totalPaid;
  final double remainingBudget;
  final double budgetUsedPercent;
  final bool isOverBudget;
  final List<InvoiceModel> linkedInvoices;

  const ProjectFinancialSummary({
    required this.budget,
    required this.totalInvoiced,
    required this.totalPaid,
    required this.remainingBudget,
    required this.budgetUsedPercent,
    required this.isOverBudget,
    required this.linkedInvoices,
  });
}

final projectFinancialSummaryProvider =
    Provider.family<ProjectFinancialSummary, String>((ref, projectId) {
  final project = ref.watch(projectByIdProvider(projectId)).asData?.value;
  final allInvoices = ref.watch(invoicesStreamProvider).asData?.value ?? [];

  // Match invoices associated with this project or client
  final linkedInvoices = allInvoices
      .where((inv) =>
          inv.projectId == projectId ||
          (project != null && inv.clientId == project.clientId))
      .toList();

  final budget = project?.budget ?? 0.0;
  final totalInvoiced = linkedInvoices.fold<double>(0.0, (s, i) => s + i.totalAmount);
  final totalPaid = linkedInvoices.fold<double>(0.0, (s, i) => s + i.amountPaid);
  final remainingBudget = (budget - totalInvoiced).clamp(0.0, double.infinity);
  final budgetUsedPercent = budget > 0 ? ((totalInvoiced / budget) * 100).clamp(0.0, 100.0) : 0.0;

  return ProjectFinancialSummary(
    budget: budget,
    totalInvoiced: totalInvoiced,
    totalPaid: totalPaid,
    remainingBudget: remainingBudget,
    budgetUsedPercent: budgetUsedPercent,
    isOverBudget: totalInvoiced > budget && budget > 0,
    linkedInvoices: linkedInvoices,
  );
});

// =============================================================================
// 4. NEEDS FOLLOW-UP CHASER SUMMARY AGGREGATOR
// =============================================================================

@immutable
class NeedsFollowUpSummary {
  final List<InvoiceModel> items;
  final double totalOverdueAmount;
  final int overdueCount;
  final int dueTodayCount;

  const NeedsFollowUpSummary({
    required this.items,
    required this.totalOverdueAmount,
    required this.overdueCount,
    required this.dueTodayCount,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

final needsFollowUpSummaryProvider = Provider<NeedsFollowUpSummary>((ref) {
  final invoices = ref.watch(invoicesStreamProvider).asData?.value ?? kSeedInvoices;

  // Filter and sort by urgency (highest days overdue first)
  final overdueItems = invoices
      .where((i) => i.isOverdue || i.status == InvoiceStatus.overdue)
      .toList()
    ..sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));

  final totalOverdue = overdueItems.fold<double>(0.0, (s, i) => s + i.balanceDue);

  final now = DateTime.now();
  final dueTodayCount = invoices.where((i) {
    return i.status != InvoiceStatus.paid &&
        i.dueDate.year == now.year &&
        i.dueDate.month == now.month &&
        i.dueDate.day == now.day;
  }).length;

  return NeedsFollowUpSummary(
    items: overdueItems,
    totalOverdueAmount: totalOverdue,
    overdueCount: overdueItems.length,
    dueTodayCount: dueTodayCount,
  );
});

// =============================================================================
// 5. INVOICES SCREEN SUMMARY METRICS AGGREGATOR
// =============================================================================

@immutable
class InvoicesScreenSummary {
  final int totalCount;
  final int paidCount;
  final int overdueCount;
  final int draftCount;
  final int sentCount;
  final double totalVolume;
  final double paidVolume;
  final double outstandingVolume;

  const InvoicesScreenSummary({
    required this.totalCount,
    required this.paidCount,
    required this.overdueCount,
    required this.draftCount,
    required this.sentCount,
    required this.totalVolume,
    required this.paidVolume,
    required this.outstandingVolume,
  });
}

final invoicesSummaryProvider = Provider<InvoicesScreenSummary>((ref) {
  final invoices = ref.watch(invoicesStreamProvider).asData?.value ?? kSeedInvoices;

  int paidCount = 0;
  int overdueCount = 0;
  int draftCount = 0;
  int sentCount = 0;
  double totalVolume = 0.0;
  double paidVolume = 0.0;
  double outstandingVolume = 0.0;

  for (final inv in invoices) {
    totalVolume += inv.totalAmount;
    paidVolume += inv.amountPaid;
    outstandingVolume += inv.balanceDue;

    switch (inv.status) {
      case InvoiceStatus.paid:
        paidCount++;
        break;
      case InvoiceStatus.overdue:
        overdueCount++;
        break;
      case InvoiceStatus.draft:
        draftCount++;
        break;
      case InvoiceStatus.sent:
      case InvoiceStatus.viewed:
        sentCount++;
        break;
    }
  }

  return InvoicesScreenSummary(
    totalCount: invoices.length,
    paidCount: paidCount,
    overdueCount: overdueCount,
    draftCount: draftCount,
    sentCount: sentCount,
    totalVolume: totalVolume,
    paidVolume: paidVolume,
    outstandingVolume: outstandingVolume,
  );
});
