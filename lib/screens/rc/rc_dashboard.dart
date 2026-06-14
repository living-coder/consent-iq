import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class RCDashboard extends StatelessWidget {
  const RCDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final data = context.watch<DataProvider>();
    final rc = data.getResearchCenter(user.entityId ?? '');
    final participants = data.participantsByRC(user.entityId ?? '');
    final studies = data.studiesForRC(user.entityId ?? '');

    final consented =
        participants.where((p) => p.consentStatus == ConsentStatus.consented).length;
    final pending =
        participants.where((p) => p.consentStatus == ConsentStatus.pending).length;
    final declined =
        participants.where((p) => p.consentStatus == ConsentStatus.declined).length;
    final withdrawn =
        participants.where((p) => p.consentStatus == ConsentStatus.withdrawn).length;
    final unassigned =
        participants.where((p) => p.assignedStudyId == null).length;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rc != null)
              Card(
                elevation: 0,
                color: const Color(0xFFE0F2F1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF00695C),
                        child:
                            Icon(Icons.local_hospital, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rc.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(rc.location,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const PageHeader(
              title: 'Research Center Dashboard',
              subtitle: 'Manage participants and track consent status',
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                    title: 'Participants',
                    value: '${participants.length}',
                    icon: Icons.people,
                    color: const Color(0xFF6A1B9A)),
                StatCard(
                    title: 'Consented',
                    value: '$consented',
                    icon: Icons.verified,
                    color: const Color(0xFF2E7D32)),
                StatCard(
                    title: 'Pending Consent',
                    value: '$pending',
                    icon: Icons.pending_actions,
                    color: const Color(0xFFF57C00)),
                StatCard(
                    title: 'Assigned Studies',
                    value: '${studies.length}',
                    icon: Icons.science,
                    color: const Color(0xFF1565C0)),
              ],
            ),
            const SizedBox(height: 28),

            // Consent status breakdown
            Card(
              elevation: 1,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consent Status Breakdown',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    _ProgressBar(
                        label: 'Consented',
                        count: consented,
                        total: participants.length,
                        color: const Color(0xFF2E7D32)),
                    const SizedBox(height: 8),
                    _ProgressBar(
                        label: 'Pending',
                        count: pending,
                        total: participants.length,
                        color: const Color(0xFFF57C00)),
                    const SizedBox(height: 8),
                    _ProgressBar(
                        label: 'Declined',
                        count: declined,
                        total: participants.length,
                        color: const Color(0xFFC62828)),
                    const SizedBox(height: 8),
                    _ProgressBar(
                        label: 'Withdrawn',
                        count: withdrawn,
                        total: participants.length,
                        color: const Color(0xFF757575)),
                    if (unassigned > 0) ...[
                      const SizedBox(height: 8),
                      _ProgressBar(
                          label: 'No study assigned',
                          count: unassigned,
                          total: participants.length,
                          color: Colors.grey),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assigned studies
            SectionCard(
              title: 'Assigned Clinical Studies',
              icon: Icons.science_outlined,
              children: studies.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            'No clinical studies assigned to this center yet.'),
                      )
                    ]
                  : studies.map((s) {
                      final sponsor = data.getSponsor(s.sponsorId);
                      final studyParticipants =
                          data.participantsByStudy(s.id).where((p) =>
                              p.researchCenterId == (user.entityId ?? '')).toList();
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFFFF3E0),
                          child: Text(s.phase.replaceAll('Phase ', ''),
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100))),
                        ),
                        title: Text(s.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13)),
                        subtitle: Text(
                            '${sponsor?.name ?? '—'} · ${studyParticipants.length} participants from this center',
                            style: const TextStyle(fontSize: 11)),
                        trailing: StatusChip(
                            label: s.status.label, color: s.status.color),
                        dense: true,
                      );
                    }).toList(),
            ),
            const SizedBox(height: 16),

            // Recent participants
            SectionCard(
              title: 'Participants',
              icon: Icons.people_outlined,
              children: participants.take(5).map((p) {
                final study = p.assignedStudyId != null
                    ? data.getStudy(p.assignedStudyId!)
                    : null;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        p.consentStatus.color.withOpacity(0.12),
                    child: Text(p.name[0],
                        style: TextStyle(
                            color: p.consentStatus.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  title: Text('${p.name}, ${p.age}y ${p.gender}',
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                      study?.title ?? 'No study assigned',
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis),
                  trailing: StatusChip(
                      label: p.consentStatus.label,
                      color: p.consentStatus.color),
                );
              }).toList(),
            ),
          ],
        ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _ProgressBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ],
    );
  }
}
