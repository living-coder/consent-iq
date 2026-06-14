import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'consent_screen.dart';

class ParticipantDashboard extends StatelessWidget {
  const ParticipantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final data = context.watch<DataProvider>();
    final participant = data.getParticipant(user.entityId ?? '');

    if (participant == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('My Study'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Your participant record could not be found.',
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),
              Text('Please contact your research center.',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final study = participant.assignedStudyId != null
        ? data.getStudy(participant.assignedStudyId!)
        : null;
    final sponsor =
        study != null ? data.getSponsor(study.sponsorId) : null;
    final rc = data.getResearchCenter(participant.researchCenterId);
    final fmt = DateFormat('MMMM d, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Welcome, ${user.name.split(' ').first}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Participant info card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            const Color(0xFF2E7D32).withOpacity(0.12),
                        child: Text(participant.name[0],
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(participant.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17)),
                            Text('${participant.age} years · ${participant.gender}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            Text(participant.email,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (rc != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Research Center',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text(rc.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 13)),
                            Text(rc.location,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Consent status banner
              _ConsentBanner(participant: participant, fmt: fmt),
              const SizedBox(height: 20),

              // Study info
              if (study == null)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No study assigned yet',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 6),
                        Text(
                            'Your research center coordinator will assign you to a clinical study soon.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else ...[
                const PageHeader(title: 'Your Assigned Clinical Study'),
                const SizedBox(height: 12),
                _StudyCard(study: study, sponsor: sponsor),
                const SizedBox(height: 20),

                // Consent action
                if (participant.consentStatus == ConsentStatus.pending)
                  Card(
                    elevation: 0,
                    color: const Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFFE082))),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outlined,
                                  color: Color(0xFFF57C00)),
                              SizedBox(width: 8),
                              Text('Your Consent is Required',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF5D4037))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                              'You have been assigned to a clinical study. Please review the Informed Consent Form (ICF) carefully and indicate whether you agree to participate.',
                              style: TextStyle(
                                  color: Color(0xFF5D4037), fontSize: 13,
                                  height: 1.5)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ConsentScreen(
                                    participantId: participant.id,
                                    studyId: study.id),
                              )),
                              icon: const Icon(Icons.assignment_outlined),
                              label: const Text('Review & Provide Consent',
                                  style: TextStyle(fontSize: 15)),
                              style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (participant.consentStatus == ConsentStatus.consented) ...[
                  Card(
                    elevation: 0,
                    color: const Color(0xFFE8F5E9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFA5D6A7))),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFF2E7D32)),
                              SizedBox(width: 8),
                              Text('You Have Consented',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1B5E20))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                              'Thank you for agreeing to participate in this clinical study. Your research center coordinator will be in touch with next steps.',
                              style: TextStyle(
                                  color: Color(0xFF2E7D32), fontSize: 13)),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => const ConfirmDialog(
                                  title: 'Withdraw Consent',
                                  content:
                                      'Are you sure you want to withdraw your consent? You can re-enrol at any time by contacting your research center.',
                                  confirmLabel: 'Withdraw',
                                ),
                              );
                              if (ok == true && context.mounted) {
                                context
                                    .read<DataProvider>()
                                    .withdrawConsent(participant.id);
                              }
                            },
                            icon: const Icon(Icons.undo, size: 16),
                            label: const Text('Withdraw Consent'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (participant.consentStatus == ConsentStatus.declined ||
                    participant.consentStatus == ConsentStatus.withdrawn) ...[
                  Card(
                    elevation: 0,
                    color: const Color(0xFFFBE9E7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFFAB91))),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cancel_outlined,
                                  color: Color(0xFFC62828)),
                              const SizedBox(width: 8),
                              Text(
                                  participant.consentStatus ==
                                          ConsentStatus.declined
                                      ? 'You Declined Participation'
                                      : 'Consent Withdrawn',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFFB71C1C))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                              'You are not currently participating in this study. You may change your decision at any time by contacting your research center coordinator.',
                              style: TextStyle(
                                  color: Color(0xFFC62828), fontSize: 13)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ConsentScreen(
                                  participantId: participant.id,
                                  studyId: study.id),
                            )),
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Review Consent Form Again'),
                            style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentBanner extends StatelessWidget {
  final Participant participant;
  final DateFormat fmt;
  const _ConsentBanner({required this.participant, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final status = participant.consentStatus;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            status == ConsentStatus.consented
                ? Icons.verified
                : status == ConsentStatus.pending
                    ? Icons.pending_actions
                    : status == ConsentStatus.declined
                        ? Icons.cancel_outlined
                        : Icons.undo,
            color: status.color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consent Status: ${status.label}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status.color,
                      fontSize: 15)),
              if (status == ConsentStatus.consented &&
                  participant.consentDate != null)
                Text(
                    'Consented on ${fmt.format(participant.consentDate!)}',
                    style: TextStyle(color: status.color, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  final ClinicalStudy study;
  final ClinicalStudySponsor? sponsor;
  const _StudyCard({required this.study, this.sponsor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(study.phase,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                StatusChip(label: study.status.label, color: study.status.color),
              ],
            ),
            const SizedBox(height: 10),
            Text(study.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4),
            if (sponsor != null)
              Text('Sponsored by ${sponsor!.name}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 24),
            InfoRow(label: 'Therapeutic Area', value: study.therapeuticArea),
            InfoRow(label: 'Indication', value: study.indication),
            InfoRow(label: 'Study Phase', value: study.phase),
            InfoRow(
                label: 'Target Enrollment',
                value: '${study.targetEnrollment} participants'),
          ],
        ),
      ),
    );
  }
}
