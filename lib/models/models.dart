import 'package:flutter/material.dart';

enum UserRole { admin, sponsor, researchCenter, participant }

enum StudyStatus { draft, active, completed, suspended }

enum ConsentStatus { pending, consented, declined, withdrawn }

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.sponsor:
        return 'Clinical Study Sponsor';
      case UserRole.researchCenter:
        return 'Research Center';
      case UserRole.participant:
        return 'Participant';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.sponsor:
        return Icons.business;
      case UserRole.researchCenter:
        return Icons.local_hospital;
      case UserRole.participant:
        return Icons.person;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.admin:
        return const Color(0xFF6A1B9A);
      case UserRole.sponsor:
        return const Color(0xFF1565C0);
      case UserRole.researchCenter:
        return const Color(0xFF00695C);
      case UserRole.participant:
        return const Color(0xFF2E7D32);
    }
  }
}

extension StudyStatusExt on StudyStatus {
  String get label {
    switch (this) {
      case StudyStatus.draft:
        return 'Draft';
      case StudyStatus.active:
        return 'Active';
      case StudyStatus.completed:
        return 'Completed';
      case StudyStatus.suspended:
        return 'Suspended';
    }
  }

  Color get color {
    switch (this) {
      case StudyStatus.draft:
        return const Color(0xFF1565C0);
      case StudyStatus.active:
        return const Color(0xFF2E7D32);
      case StudyStatus.completed:
        return const Color(0xFF757575);
      case StudyStatus.suspended:
        return const Color(0xFFC62828);
    }
  }
}

extension ConsentStatusExt on ConsentStatus {
  String get label {
    switch (this) {
      case ConsentStatus.pending:
        return 'Pending';
      case ConsentStatus.consented:
        return 'Consented';
      case ConsentStatus.declined:
        return 'Declined';
      case ConsentStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  Color get color {
    switch (this) {
      case ConsentStatus.pending:
        return const Color(0xFFF57C00);
      case ConsentStatus.consented:
        return const Color(0xFF2E7D32);
      case ConsentStatus.declined:
        return const Color(0xFFC62828);
      case ConsentStatus.withdrawn:
        return const Color(0xFF757575);
    }
  }
}

class User {
  final String id;
  String name;
  String email;
  final String password;
  final UserRole role;
  final String? entityId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.entityId,
  });
}

class ClinicalStudySponsor {
  final String id;
  String name;
  String contactEmail;
  String description;

  ClinicalStudySponsor({
    required this.id,
    required this.name,
    required this.contactEmail,
    required this.description,
  });
}

class ResearchCenter {
  final String id;
  String name;
  String location;
  String contactEmail;

  ResearchCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.contactEmail,
  });
}

class ClinicalStudy {
  final String id;
  String title;
  String sponsorId;
  String phase;
  StudyStatus status;
  String description;
  String? protocolDocumentName;
  String therapeuticArea;
  String indication;
  int targetEnrollment;
  List<String> researchCenterIds;

  ClinicalStudy({
    required this.id,
    required this.title,
    required this.sponsorId,
    required this.phase,
    required this.status,
    required this.description,
    this.protocolDocumentName,
    required this.therapeuticArea,
    required this.indication,
    required this.targetEnrollment,
    List<String>? researchCenterIds,
  }) : researchCenterIds = researchCenterIds ?? [];
}

class Participant {
  final String id;
  String name;
  String email;
  String researchCenterId;
  String? assignedStudyId;
  ConsentStatus consentStatus;
  DateTime? consentDate;
  int age;
  String gender;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.researchCenterId,
    this.assignedStudyId,
    this.consentStatus = ConsentStatus.pending,
    this.consentDate,
    required this.age,
    required this.gender,
  });
}
