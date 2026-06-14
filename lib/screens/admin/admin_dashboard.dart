import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final data = context.watch<DataProvider>();

    final activeStudies =
        data.allStudies.where((s) => s.status == StudyStatus.active).length;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Administrator Dashboard',
              subtitle: 'System-wide overview and management',
            ),
            const SizedBox(height: 24),

            // Stats
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                    title: 'Sponsors',
                    value: '${data.sponsors.length}',
                    icon: Icons.business,
                    color: const Color(0xFF1565C0)),
                StatCard(
                    title: 'Research Centers',
                    value: '${data.researchCenters.length}',
                    icon: Icons.local_hospital,
                    color: const Color(0xFF00695C)),
                StatCard(
                    title: 'Active Studies',
                    value: '$activeStudies',
                    icon: Icons.science,
                    color: const Color(0xFFE65100)),
              ],
            ),
            const SizedBox(height: 28),

            // Two columns
            LayoutBuilder(builder: (context, c) {
              final twoCol = c.maxWidth > 700;
              final sponsorCard = SectionCard(
                title: 'Clinical Study Sponsors',
                icon: Icons.business_outlined,
                children: data.sponsors
                    .map((s) => ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFE3F2FD),
                            child: const Icon(Icons.business,
                                size: 16, color: Color(0xFF1565C0)),
                          ),
                          title: Text(s.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13)),
                          subtitle: Text(s.contactEmail,
                              style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                              '${data.studiesBySponsor(s.id).length} studies',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ))
                    .toList(),
              );

              final rcCard = SectionCard(
                title: 'Research Centers',
                icon: Icons.local_hospital_outlined,
                children: data.researchCenters
                    .map((rc) => ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFE0F2F1),
                            child: const Icon(Icons.local_hospital,
                                size: 16, color: Color(0xFF00695C)),
                          ),
                          title: Text(rc.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13)),
                          subtitle: Text(rc.location,
                              style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                              '${data.studiesForRC(rc.id).length} studies',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ))
                    .toList(),
              );

              if (twoCol) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: sponsorCard),
                    const SizedBox(width: 16),
                    Expanded(child: rcCard),
                  ],
                );
              }
              return Column(children: [
                sponsorCard,
                const SizedBox(height: 16),
                rcCard,
              ]);
            }),

            const SizedBox(height: 16),

            // Studies
            SectionCard(
              title: 'All Clinical Studies',
              icon: Icons.science_outlined,
              children: data.allStudies.map((s) {
                final sponsor = data.getSponsor(s.sponsorId);
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFFF3E0),
                    child: Text(s.phase.replaceAll('Phase ', ''),
                        style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(s.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13)),
                  subtitle: Text(
                      '${sponsor?.name ?? '—'} · ${s.therapeuticArea}',
                      style: const TextStyle(fontSize: 12)),
                  trailing: StatusChip(label: s.status.label, color: s.status.color),
                );
              }).toList(),
            ),

          ],
        ),
    );
  }
}
