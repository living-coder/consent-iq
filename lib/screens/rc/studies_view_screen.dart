import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class StudiesViewScreen extends StatelessWidget {
  const StudiesViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final data = context.watch<DataProvider>();
    final studies = data.studiesForRC(user.entityId ?? '');

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Clinical Studies',
              subtitle:
                  '${studies.length} ${studies.length == 1 ? 'study' : 'studies'} assigned to your center',
            ),
            const SizedBox(height: 24),

            if (studies.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.science_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                        'No clinical studies assigned to your center yet.',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    const Text(
                        'Contact your study sponsor to be assigned to a trial.',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
            else
              ...studies.map((s) {
                final sponsor = data.getSponsor(s.sponsorId);
                final myParticipants = data
                    .participantsByStudy(s.id)
                    .where((p) => p.researchCenterId == (user.entityId ?? ''))
                    .toList();
                final consented = myParticipants
                    .where((p) => p.consentStatus == ConsentStatus.consented)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFF3E0),
                        child: Text(s.phase.replaceAll('Phase ', ''),
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100))),
                      ),
                      title: Text(s.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                          '${sponsor?.name ?? '—'} · ${s.therapeuticArea}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusChip(
                              label: s.status.label, color: s.status.color),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),

                        // Study details
                        InfoRow(label: 'Phase', value: s.phase),
                        InfoRow(label: 'Therapeutic Area', value: s.therapeuticArea),
                        InfoRow(label: 'Indication', value: s.indication),
                        InfoRow(
                            label: 'Target Enrollment',
                            value: '${s.targetEnrollment} participants'),
                        if (s.protocolDocumentName != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 140,
                                  child: Text('Protocol Document',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13)),
                                ),
                                const Icon(Icons.attach_file,
                                    size: 14, color: Color(0xFF1565C0)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(s.protocolDocumentName!,
                                      style: const TextStyle(
                                          color: Color(0xFF1565C0),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        const Text('Study Description',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(s.description,
                            style: const TextStyle(fontSize: 13, height: 1.5)),
                        const SizedBox(height: 16),

                        // My participants in this study
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Participants from Your Center',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  const Spacer(),
                                  Text('$consented/${myParticipants.length} consented',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              if (myParticipants.isEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                    'No participants from your center enrolled in this study yet.',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ] else ...[
                                const SizedBox(height: 8),
                                ...myParticipants.map((p) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: p.consentStatus
                                                .color
                                                .withOpacity(0.12),
                                            child: Text(p.name[0],
                                                style: TextStyle(
                                                    color:
                                                        p.consentStatus.color,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                                '${p.name}, ${p.age}y',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ),
                                          StatusChip(
                                              label: p.consentStatus.label,
                                              color: p.consentStatus.color),
                                        ],
                                      ),
                                    )),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
    );
  }
}
