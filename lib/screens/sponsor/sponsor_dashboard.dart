import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class SponsorDashboard extends StatelessWidget {
  const SponsorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final data = context.watch<DataProvider>();
    final sponsor = data.getSponsor(user.entityId ?? '');
    final studies = sponsor != null ? data.studiesBySponsor(sponsor.id) : <ClinicalStudy>[];
    final activeStudies =
        studies.where((s) => s.status == StudyStatus.active).length;
    final assignedRCs = studies
        .expand((s) => s.researchCenterIds)
        .toSet()
        .length;
    final totalParticipants = studies
        .expand((s) => data.participantsByStudy(s.id))
        .length;
    final consented = studies
        .expand((s) => data.participantsByStudy(s.id))
        .where((p) => p.consentStatus == ConsentStatus.consented)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Welcome, ${user.name.split(' ').first}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sponsor != null)
              Card(
                color: const Color(0xFFE3F2FD),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF1565C0),
                        child: Icon(Icons.business, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sponsor.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(sponsor.description,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            const PageHeader(
              title: 'Sponsor Dashboard',
              subtitle: 'Overview of your clinical studies and enrollment',
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                    title: 'Total Studies',
                    value: '${studies.length}',
                    icon: Icons.science,
                    color: const Color(0xFF1565C0)),
                StatCard(
                    title: 'Active Studies',
                    value: '$activeStudies',
                    icon: Icons.play_circle_outline,
                    color: const Color(0xFF2E7D32)),
                StatCard(
                    title: 'Research Centers',
                    value: '$assignedRCs',
                    icon: Icons.local_hospital,
                    color: const Color(0xFF00695C)),
                StatCard(
                    title: 'Participants',
                    value: '$totalParticipants',
                    icon: Icons.people,
                    color: const Color(0xFF6A1B9A)),
                StatCard(
                    title: 'Consented',
                    value: '$consented',
                    icon: Icons.verified,
                    color: const Color(0xFF2E7D32)),
              ],
            ),
            const SizedBox(height: 28),

            SectionCard(
              title: 'My Clinical Studies',
              icon: Icons.science_outlined,
              children: studies.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            'No studies yet. Create one from the Clinical Studies section.'),
                      )
                    ]
                  : studies.map((s) {
                      final participants = data.participantsByStudy(s.id);
                      final pConsented = participants
                          .where(
                              (p) => p.consentStatus == ConsentStatus.consented)
                          .length;
                      final enrollmentPct = s.targetEnrollment > 0
                          ? participants.length / s.targetEnrollment
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(s.phase,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE65100))),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(s.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                StatusChip(
                                    label: s.status.label,
                                    color: s.status.color),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${s.therapeuticArea} · ${s.indication}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${participants.length} / ${s.targetEnrollment} enrolled',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                          Text('$pConsented consented',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF2E7D32))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: enrollmentPct.clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey[200],
                                        color: const Color(0xFF1565C0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                    '${s.researchCenterIds.length} center${s.researchCenterIds.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const Divider(height: 24),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
