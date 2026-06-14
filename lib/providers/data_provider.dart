import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/mock_store.dart';

class DataProvider extends ChangeNotifier {
  final MockStore _store = MockStore();

  // ── Users ──────────────────────────────────────────────────────────────────
  List<User> get allUsers => List.unmodifiable(_store.users);
  List<User> get adminUsers => _store.users.where((u) => u.role == UserRole.admin).toList();

  void addUser(User user) {
    _store.users.add(user);
    notifyListeners();
  }

  void removeUser(String id) {
    _store.users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  // ── Sponsors ───────────────────────────────────────────────────────────────
  List<ClinicalStudySponsor> get sponsors => List.unmodifiable(_store.sponsors);

  ClinicalStudySponsor? getSponsor(String id) {
    try {
      return _store.sponsors.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void addSponsor(ClinicalStudySponsor sponsor) {
    _store.sponsors.add(sponsor);
    notifyListeners();
  }

  void updateSponsor(String id, {String? name, String? contactEmail, String? description}) {
    try {
      final s = _store.sponsors.firstWhere((s) => s.id == id);
      if (name != null) s.name = name;
      if (contactEmail != null) s.contactEmail = contactEmail;
      if (description != null) s.description = description;
      notifyListeners();
    } catch (_) {}
  }

  void removeSponsor(String id) {
    _store.sponsors.removeWhere((s) => s.id == id);
    _store.users.removeWhere((u) => u.role == UserRole.sponsor && u.entityId == id);
    notifyListeners();
  }

  List<User> usersForSponsor(String sponsorId) =>
      _store.users.where((u) => u.role == UserRole.sponsor && u.entityId == sponsorId).toList();

  // ── Research Centers ───────────────────────────────────────────────────────
  List<ResearchCenter> get researchCenters => List.unmodifiable(_store.researchCenters);

  ResearchCenter? getResearchCenter(String id) {
    try {
      return _store.researchCenters.firstWhere((rc) => rc.id == id);
    } catch (_) {
      return null;
    }
  }

  void addResearchCenter(ResearchCenter rc) {
    _store.researchCenters.add(rc);
    notifyListeners();
  }

  void updateResearchCenter(String id, {String? name, String? location, String? contactEmail}) {
    try {
      final rc = _store.researchCenters.firstWhere((r) => r.id == id);
      if (name != null) rc.name = name;
      if (location != null) rc.location = location;
      if (contactEmail != null) rc.contactEmail = contactEmail;
      notifyListeners();
    } catch (_) {}
  }

  void removeResearchCenter(String id) {
    _store.researchCenters.removeWhere((rc) => rc.id == id);
    _store.users.removeWhere((u) => u.role == UserRole.researchCenter && u.entityId == id);
    notifyListeners();
  }

  List<User> usersForRC(String rcId) =>
      _store.users.where((u) => u.role == UserRole.researchCenter && u.entityId == rcId).toList();

  // ── Clinical Studies ───────────────────────────────────────────────────────
  List<ClinicalStudy> get allStudies => List.unmodifiable(_store.studies);

  List<ClinicalStudy> studiesBySponsor(String sponsorId) =>
      _store.studies.where((s) => s.sponsorId == sponsorId).toList();

  List<ClinicalStudy> studiesForRC(String rcId) =>
      _store.studies.where((s) => s.researchCenterIds.contains(rcId)).toList();

  ClinicalStudy? getStudy(String id) {
    try {
      return _store.studies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void addStudy(ClinicalStudy study) {
    _store.studies.add(study);
    notifyListeners();
  }

  void updateStudy(
    String id, {
    String? title,
    String? phase,
    StudyStatus? status,
    String? description,
    String? protocolDocumentName,
    String? therapeuticArea,
    String? indication,
    int? targetEnrollment,
  }) {
    try {
      final s = _store.studies.firstWhere((s) => s.id == id);
      if (title != null) s.title = title;
      if (phase != null) s.phase = phase;
      if (status != null) s.status = status;
      if (description != null) s.description = description;
      if (protocolDocumentName != null) s.protocolDocumentName = protocolDocumentName;
      if (therapeuticArea != null) s.therapeuticArea = therapeuticArea;
      if (indication != null) s.indication = indication;
      if (targetEnrollment != null) s.targetEnrollment = targetEnrollment;
      notifyListeners();
    } catch (_) {}
  }

  void removeStudy(String id) {
    _store.studies.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void assignRCToStudy(String studyId, String rcId) {
    try {
      final s = _store.studies.firstWhere((s) => s.id == studyId);
      if (!s.researchCenterIds.contains(rcId)) {
        s.researchCenterIds.add(rcId);
        notifyListeners();
      }
    } catch (_) {}
  }

  void removeRCFromStudy(String studyId, String rcId) {
    try {
      final s = _store.studies.firstWhere((s) => s.id == studyId);
      s.researchCenterIds.remove(rcId);
      notifyListeners();
    } catch (_) {}
  }

  // ── Participants ───────────────────────────────────────────────────────────
  List<Participant> get allParticipants => List.unmodifiable(_store.participants);

  List<Participant> participantsByRC(String rcId) =>
      _store.participants.where((p) => p.researchCenterId == rcId).toList();

  List<Participant> participantsByStudy(String studyId) =>
      _store.participants.where((p) => p.assignedStudyId == studyId).toList();

  Participant? getParticipant(String id) {
    try {
      return _store.participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void addParticipant(Participant participant) {
    _store.participants.add(participant);
    notifyListeners();
  }

  void assignStudyToParticipant(String participantId, String studyId) {
    try {
      final p = _store.participants.firstWhere((p) => p.id == participantId);
      p.assignedStudyId = studyId;
      p.consentStatus = ConsentStatus.pending;
      notifyListeners();
    } catch (_) {}
  }

  void removeParticipant(String id) {
    _store.participants.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void submitConsent(String participantId, {required bool consented}) {
    try {
      final p = _store.participants.firstWhere((p) => p.id == participantId);
      p.consentStatus = consented ? ConsentStatus.consented : ConsentStatus.declined;
      if (consented) p.consentDate = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }

  void withdrawConsent(String participantId) {
    try {
      final p = _store.participants.firstWhere((p) => p.id == participantId);
      p.consentStatus = ConsentStatus.withdrawn;
      p.consentDate = null;
      notifyListeners();
    } catch (_) {}
  }

  String generateId() => 'id_${DateTime.now().millisecondsSinceEpoch}';
}
