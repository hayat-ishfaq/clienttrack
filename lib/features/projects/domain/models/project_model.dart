import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum ProjectStatus {
  notStarted,
  inProgress,
  planning,
  completed,
  onHold;

  String get label {
    switch (this) {
      case ProjectStatus.notStarted:
        return 'Not Started';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
    }
  }

  static ProjectStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'notstarted':
      case 'not started':
        return ProjectStatus.notStarted;
      case 'inprogress':
      case 'in progress':
      case 'in_progress':
        return ProjectStatus.inProgress;
      case 'planning':
        return ProjectStatus.planning;
      case 'completed':
        return ProjectStatus.completed;
      case 'onhold':
      case 'on hold':
      case 'on_hold':
        return ProjectStatus.onHold;
      default:
        return ProjectStatus.inProgress;
    }
  }
}

enum RateType {
  fixed,
  hourly;

  String get label => this == RateType.fixed ? 'Fixed Rate' : 'Hourly Rate';

  static RateType fromString(String? value) {
    if (value?.toLowerCase() == 'hourly') {
      return RateType.hourly;
    }
    return RateType.fixed;
  }
}

@immutable
class ProjectModel {
  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final ProjectStatus status;
  final RateType rateType;
  final double budget;
  final DateTime? deadline;
  final double progressPct; // 0.0 - 1.0
  final bool autoInvoicingEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    this.description = '',
    this.status = ProjectStatus.inProgress,
    this.rateType = RateType.fixed,
    this.budget = 0.0,
    this.deadline,
    this.progressPct = 0.0,
    this.autoInvoicingEnabled = true,
    this.createdAt,
    this.updatedAt,
  });

  ProjectModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? title,
    String? description,
    ProjectStatus? status,
    RateType? rateType,
    double? budget,
    DateTime? deadline,
    double? progressPct,
    bool? autoInvoicingEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      rateType: rateType ?? this.rateType,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      progressPct: progressPct ?? this.progressPct,
      autoInvoicingEnabled: autoInvoicingEnabled ?? this.autoInvoicingEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'title': title,
      'description': description,
      'status': status.name,
      'rateType': rateType.name,
      'budget': budget,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'progressPct': progressPct,
      'autoInvoicingEnabled': autoInvoicingEnabled,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ProjectModel(
      id: id,
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: ProjectStatus.fromString(map['status'] as String?),
      rateType: RateType.fromString(map['rateType'] as String?),
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      deadline: parseDate(map['deadline']),
      progressPct: (map['progressPct'] as num?)?.toDouble() ?? 0.0,
      autoInvoicingEnabled: map['autoInvoicingEnabled'] as bool? ?? true,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ProjectModel.fromMap(data, doc.id);
  }
}
