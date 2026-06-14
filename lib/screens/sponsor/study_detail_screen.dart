import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class StudyDetailScreen extends StatelessWidget {
  final String studyId;
  const StudyDetailScreen({super.key, required this.studyId});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final study = data.getStudy(studyId);
    if (study == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Not Found')),
        body: const Center(child: Text('This study no longer exists.')),
      );
    }
    final sponsor = data.getSponsor(study.sponsorId);
    final participants = data.participantsByStudy(study.id);
    final consented =
        participants.where((p) => p.consentStatus == ConsentStatus.consented).length;
    final pending =
        participants.where((p) => p.consentStatus == ConsentStatus.pending).length;
    final declined =
        participants.where((p) => p.consentStatus == ConsentStatus.declined).length;
    final enrollmentPct = study.targetEnrollment > 0
        ? participants.length / study.targetEnrollment
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(study.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit study',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _EditStudyDialog(study: study),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              elevation: 1,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                                  color: Color(0xFFE65100))),
                        ),
                        const SizedBox(width: 10),
                        StatusChip(
                            label: study.status.label, color: study.status.color),
                        const Spacer(),
                        DropdownButton<StudyStatus>(
                          value: study.status,
                          underline: const SizedBox(),
                          items: StudyStatus.values
                              .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('Set: ${s.label}',
                                      style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (s) {
                            if (s != null) {
                              data.updateStudy(study.id, status: s);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(study.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Sponsored by ${sponsor?.name ?? '—'}',
                        style: const TextStyle(color: Colors.grey)),
                    const Divider(height: 28),
                    InfoRow(label: 'Therapeutic Area', value: study.therapeuticArea),
                    InfoRow(label: 'Indication', value: study.indication),
                    InfoRow(
                        label: 'Target Enrollment',
                        value: '${study.targetEnrollment} participants'),
                    if (study.protocolDocumentName != null)
                      InfoRow(
                          label: 'Protocol Document',
                          value: study.protocolDocumentName!),
                    const SizedBox(height: 12),
                    Text('Study Description',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Text(study.description,
                        style: const TextStyle(fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Enrollment progress
            Card(
              elevation: 1,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enrollment & Consent Summary',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${participants.length} of ${study.targetEnrollment} participants enrolled',
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: enrollmentPct.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[200],
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                            '${(enrollmentPct * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18,
                                color: Color(0xFF1565C0))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _CountChip(label: 'Consented', count: consented,
                            color: const Color(0xFF2E7D32)),
                        _CountChip(label: 'Pending', count: pending,
                            color: const Color(0xFFF57C00)),
                        _CountChip(label: 'Declined', count: declined,
                            color: const Color(0xFFC62828)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Research centers
            SectionCard(
              title: 'Assigned Research Centers',
              icon: Icons.local_hospital_outlined,
              trailing: TextButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _AssignRCDialog(study: study),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Assign Center', style: TextStyle(fontSize: 12)),
              ),
              children: study.researchCenterIds.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            'No research centers assigned. Click "Assign Center" to add one.'),
                      )
                    ]
                  : study.researchCenterIds.map((rcId) {
                      final rc = data.getResearchCenter(rcId);
                      final rcParticipants = participants
                          .where((p) => p.researchCenterId == rcId)
                          .toList();
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE0F2F1),
                          child: Icon(Icons.local_hospital,
                              size: 18, color: Color(0xFF00695C)),
                        ),
                        title: Text(rc?.name ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                            '${rc?.location ?? ''} · ${rcParticipants.length} participants'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          tooltip: 'Remove from study',
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => ConfirmDialog(
                                title: 'Remove Research Center',
                                content:
                                    'Remove "${rc?.name}" from this study?',
                                confirmLabel: 'Remove',
                              ),
                            );
                            if (ok == true && context.mounted) {
                              context
                                  .read<DataProvider>()
                                  .removeRCFromStudy(study.id, rcId);
                            }
                          },
                        ),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 16),

            // Participants
            if (participants.isNotEmpty)
              SectionCard(
                title: 'Enrolled Participants',
                icon: Icons.people_outlined,
                children: participants.map((p) {
                  final rc = data.getResearchCenter(p.researchCenterId);
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
                    subtitle: Text(rc?.name ?? '—',
                        style: const TextStyle(fontSize: 11)),
                    trailing: StatusChip(
                        label: p.consentStatus.label,
                        color: p.consentStatus.color),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EditStudyDialog extends StatefulWidget {
  final ClinicalStudy study;
  const _EditStudyDialog({required this.study});

  @override
  State<_EditStudyDialog> createState() => _EditStudyDialogState();
}

class _EditStudyDialogState extends State<_EditStudyDialog> {
  final _form = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.study.title);
  late final _descCtrl = TextEditingController(text: widget.study.description);
  late final _areaCtrl =
      TextEditingController(text: widget.study.therapeuticArea);
  late final _indicCtrl =
      TextEditingController(text: widget.study.indication);
  late final _enrollCtrl =
      TextEditingController(text: '${widget.study.targetEnrollment}');
  late String _phase = widget.study.phase;
  late String? _docName = widget.study.protocolDocumentName;

  static const _phases = [
    'Phase I', 'Phase I/II', 'Phase II', 'Phase III', 'Phase IV',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    _indicCtrl.dispose();
    _enrollCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<DataProvider>().updateStudy(
          widget.study.id,
          title: _titleCtrl.text.trim(),
          phase: _phase,
          description: _descCtrl.text.trim(),
          therapeuticArea: _areaCtrl.text.trim(),
          indication: _indicCtrl.text.trim(),
          targetEnrollment: int.tryParse(_enrollCtrl.text) ?? 0,
          protocolDocumentName: _docName,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Clinical Study'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Study Title'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _phase,
                  decoration: const InputDecoration(labelText: 'Phase'),
                  items: _phases
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _phase = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _areaCtrl,
                  decoration: const InputDecoration(labelText: 'Therapeutic Area'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _indicCtrl,
                  decoration: const InputDecoration(labelText: 'Indication'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _enrollCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Target Enrollment'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          _docName ?? 'No protocol document',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final name = await showDialog<String>(
                          context: context,
                          builder: (_) => const _DocNameDialog(),
                        );
                        if (name != null) setState(() => _docName = name);
                      },
                      icon: const Icon(Icons.upload_file, size: 14),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save Changes')),
      ],
    );
  }
}

class _DocNameDialog extends StatefulWidget {
  const _DocNameDialog();

  @override
  State<_DocNameDialog> createState() => _DocNameDialogState();
}

class _DocNameDialogState extends State<_DocNameDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Replace Protocol Document'),
      content: TextField(
        controller: _ctrl,
        decoration: const InputDecoration(
            labelText: 'New filename', hintText: 'Protocol_v2.0.pdf'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final n = _ctrl.text.trim();
            if (n.isNotEmpty) {
              Navigator.of(context).pop(n.endsWith('.pdf') ? n : '$n.pdf');
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class _AssignRCDialog extends StatefulWidget {
  final ClinicalStudy study;
  const _AssignRCDialog({required this.study});

  @override
  State<_AssignRCDialog> createState() => _AssignRCDialogState();
}

class _AssignRCDialogState extends State<_AssignRCDialog> {
  String? _selectedRcId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final available = data.researchCenters
        .where((rc) => !widget.study.researchCenterIds.contains(rc.id))
        .toList();

    return AlertDialog(
      title: const Text('Assign Research Center'),
      content: available.isEmpty
          ? const Text('All research centers are already assigned to this study.')
          : DropdownButtonFormField<String>(
              value: _selectedRcId,
              decoration: const InputDecoration(labelText: 'Research Center'),
              items: available
                  .map((rc) => DropdownMenuItem(
                      value: rc.id,
                      child: Text('${rc.name} (${rc.location})')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRcId = v),
            ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        if (available.isNotEmpty)
          FilledButton(
            onPressed: () {
              if (_selectedRcId != null) {
                context
                    .read<DataProvider>()
                    .assignRCToStudy(widget.study.id, _selectedRcId!);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Assign'),
          ),
      ],
    );
  }
}
