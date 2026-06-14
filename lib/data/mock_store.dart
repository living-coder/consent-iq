import '../models/models.dart';

class MockStore {
  static final MockStore _instance = MockStore._internal();
  factory MockStore() => _instance;
  MockStore._internal();

  final List<User> users = [
    User(id: 'u1', name: 'Vikram Gupta', email: 'vikramg@consentiq.com', password: 'admin123', role: UserRole.admin),
    User(id: 'u2', name: 'Bob Martinez', email: 'bob@consentiq.com', password: 'admin123', role: UserRole.admin),
    User(id: 'u3', name: 'Carol Chen', email: 'carol@pharmax.com', password: 'sponsor123', role: UserRole.sponsor, entityId: 's1'),
    User(id: 'u4', name: 'David Park', email: 'david@genethera.com', password: 'sponsor123', role: UserRole.sponsor, entityId: 's2'),
    User(id: 'u5', name: 'Dr. Emma Wilson', email: 'emma@citymedical.com', password: 'rc123', role: UserRole.researchCenter, entityId: 'rc1'),
    User(id: 'u6', name: 'Dr. Frank Torres', email: 'frank@university.edu', password: 'rc123', role: UserRole.researchCenter, entityId: 'rc2'),
    User(id: 'u7', name: 'Grace Kim', email: 'grace@email.com', password: 'patient123', role: UserRole.participant, entityId: 'p1'),
    User(id: 'u8', name: 'Henry Liu', email: 'henry@email.com', password: 'patient123', role: UserRole.participant, entityId: 'p2'),
    User(id: 'u9', name: 'Isabelle Rossi', email: 'isabelle@email.com', password: 'patient123', role: UserRole.participant, entityId: 'p3'),
  ];

  final List<ClinicalStudySponsor> sponsors = [
    ClinicalStudySponsor(
      id: 's1',
      name: 'PharmaX Inc.',
      contactEmail: 'contact@pharmax.com',
      description: 'Leading pharmaceutical innovator focused on oncology and rare diseases with a pipeline of over 20 clinical-stage assets.',
    ),
    ClinicalStudySponsor(
      id: 's2',
      name: 'GeneThera Corp.',
      contactEmail: 'info@genethera.com',
      description: 'Pioneer in gene therapy and precision medicine, developing curative treatments for rare genetic disorders.',
    ),
  ];

  final List<ResearchCenter> researchCenters = [
    ResearchCenter(id: 'rc1', name: 'City Medical Center', location: 'New York, NY', contactEmail: 'trials@citymedical.com'),
    ResearchCenter(id: 'rc2', name: 'University Hospital', location: 'Boston, MA', contactEmail: 'research@university.edu'),
    ResearchCenter(id: 'rc3', name: 'Westside Clinic', location: 'Los Angeles, CA', contactEmail: 'clinical@westsideclinic.com'),
  ];

  final List<ClinicalStudy> studies = [
    ClinicalStudy(
      id: 'cs1',
      title: 'NOVA-301: Novacept for Advanced NSCLC',
      sponsorId: 's1',
      phase: 'Phase III',
      status: StudyStatus.active,
      description:
          'A randomized, double-blind, placebo-controlled trial evaluating the efficacy and safety of Novacept (novacetinib) in patients with advanced non-small cell lung cancer who have progressed on or after first-line platinum-based chemotherapy. The primary endpoint is overall survival (OS); secondary endpoints include progression-free survival and objective response rate.',
      therapeuticArea: 'Oncology',
      indication: 'Non-Small Cell Lung Cancer (NSCLC)',
      targetEnrollment: 450,
      protocolDocumentName: 'NOVA-301_Protocol_v2.1.pdf',
      researchCenterIds: ['rc1', 'rc2'],
    ),
    ClinicalStudy(
      id: 'cs2',
      title: 'GENE-101: GT-7 Gene Therapy for Sickle Cell Disease',
      sponsorId: 's2',
      phase: 'Phase I/II',
      status: StudyStatus.active,
      description:
          'An open-label, dose-escalation study evaluating the safety, tolerability, and preliminary efficacy of GT-7, a lentiviral vector-based gene therapy, in adult patients with severe sickle cell disease (SCD). The study involves a single infusion of autologous CD34+ hematopoietic stem cells transduced with the GT-7 vector.',
      therapeuticArea: 'Hematology',
      indication: 'Sickle Cell Disease (SCD)',
      targetEnrollment: 30,
      protocolDocumentName: 'GENE-101_Protocol_v1.0.pdf',
      researchCenterIds: ['rc1'],
    ),
    ClinicalStudy(
      id: 'cs3',
      title: 'CARD-201: CardioFlex for Heart Failure',
      sponsorId: 's1',
      phase: 'Phase II',
      status: StudyStatus.active,
      description:
          'A multi-center, randomized, double-blind, placebo-controlled study evaluating the efficacy and safety of CardioFlex (cardiofleximab) in patients with heart failure with reduced ejection fraction (HFrEF). Participants will receive CardioFlex or placebo in addition to standard-of-care therapy for 52 weeks.',
      therapeuticArea: 'Cardiology',
      indication: 'Heart Failure with Reduced Ejection Fraction (HFrEF)',
      targetEnrollment: 200,
      protocolDocumentName: 'CARD-201_Protocol_v1.2.pdf',
      researchCenterIds: ['rc2', 'rc3'],
    ),
  ];

  final List<Participant> participants = [
    Participant(
      id: 'p1',
      name: 'Grace Kim',
      email: 'grace@email.com',
      researchCenterId: 'rc1',
      assignedStudyId: 'cs1',
      consentStatus: ConsentStatus.consented,
      consentDate: DateTime(2024, 3, 15),
      age: 58,
      gender: 'Female',
    ),
    Participant(
      id: 'p2',
      name: 'Henry Liu',
      email: 'henry@email.com',
      researchCenterId: 'rc1',
      assignedStudyId: 'cs2',
      consentStatus: ConsentStatus.pending,
      age: 34,
      gender: 'Male',
    ),
    Participant(
      id: 'p3',
      name: 'Isabelle Rossi',
      email: 'isabelle@email.com',
      researchCenterId: 'rc2',
      assignedStudyId: 'cs1',
      consentStatus: ConsentStatus.pending,
      age: 62,
      gender: 'Female',
    ),
    Participant(
      id: 'p4',
      name: 'James Carter',
      email: 'james@email.com',
      researchCenterId: 'rc1',
      age: 45,
      gender: 'Male',
    ),
    Participant(
      id: 'p5',
      name: 'Karen Mills',
      email: 'karen@email.com',
      researchCenterId: 'rc2',
      assignedStudyId: 'cs3',
      consentStatus: ConsentStatus.declined,
      age: 71,
      gender: 'Female',
    ),
  ];

  User? authenticate(String email, String password) {
    try {
      return users.firstWhere((u) => u.email == email && u.password == password);
    } catch (_) {
      return null;
    }
  }
}
