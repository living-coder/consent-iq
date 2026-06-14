import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'study_detail_screen.dart';

class StudiesScreen extends StatelessWidget {
  const StudiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final data = context.watch<DataProvider>();
    final studies = data.studiesBySponsor(user.entityId ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Clinical Studies'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Clinical Studies',
              subtitle: '${studies.length} studies under your sponsorship',
              action: FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _CreateStudyDialog(sponsorId: user.entityId ?? ''),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Study'),
              ),
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
                    const Text('No clinical studies yet.',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) =>
                            _CreateStudyDialog(sponsorId: user.entityId ?? ''),
                      ),
                      child: const Text('Create First Study'),
                    ),
                  ],
                ),
              )
            else
              ...studies.map((s) {
                final participants = data.participantsByStudy(s.id);
                final pct = s.targetEnrollment > 0
                    ? participants.length / s.targetEnrollment
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudyDetailScreen(studyId: s.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ),
                                StatusChip(
                                    label: s.status.label,
                                    color: s.status.color),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.biotech_outlined,
                                    size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${s.therapeuticArea} · ${s.indication}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(s.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700])),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${participants.length} / ${s.targetEnrollment} enrolled',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: pct.clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey[200],
                                        color: const Color(0xFF1565C0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (s.protocolDocumentName != null)
                                  Tooltip(
                                    message: s.protocolDocumentName!,
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.attach_file,
                                            size: 14, color: Colors.grey),
                                        Text('Protocol',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _CreateStudyDialog extends StatefulWidget {
  final String sponsorId;
  const _CreateStudyDialog({required this.sponsorId});

  @override
  State<_CreateStudyDialog> createState() => _CreateStudyDialogState();
}

class _CreateStudyDialogState extends State<_CreateStudyDialog> {
  final _form = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _indicationCtrl = TextEditingController();
  final _enrollCtrl = TextEditingController();
  String _phase = 'Phase I';
  String? _docName;

  static const _phases = [
    'Phase I',
    'Phase I/II',
    'Phase II',
    'Phase III',
    'Phase IV',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _areaCtrl.dispose();
    _indicationCtrl.dispose();
    _enrollCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final data = context.read<DataProvider>();
    data.addStudy(ClinicalStudy(
      id: data.generateId(),
      title: _titleCtrl.text.trim(),
      sponsorId: widget.sponsorId,
      phase: _phase,
      status: StudyStatus.draft,
      description: _descCtrl.text.trim(),
      therapeuticArea: _areaCtrl.text.trim(),
      indication: _indicationCtrl.text.trim(),
      targetEnrollment: int.tryParse(_enrollCtrl.text) ?? 0,
      protocolDocumentName: _docName,
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Study created.')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Clinical Study'),
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
                  decoration: const InputDecoration(
                      labelText: 'Study Title',
                      hintText: 'e.g. NOVA-301: Novacept for Advanced NSCLC'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _phase,
                  decoration: const InputDecoration(labelText: 'Phase'),
                  items: _phases
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _phase = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _areaCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Therapeutic Area',
                      hintText: 'e.g. Oncology, Cardiology'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _indicationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Indication',
                      hintText: 'e.g. Non-Small Cell Lung Cancer'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _enrollCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Target Enrollment'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Study Description'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                // Protocol document upload (simulated)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _docName ?? 'No protocol document selected',
                          style: TextStyle(
                              color: _docName != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final name = await showDialog<String>(
                          context: context,
                          builder: (_) => const _UploadDocDialog(),
                        );
                        if (name != null) setState(() => _docName = name);
                      },
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Upload'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Protocol document (PDF) is required for regulatory compliance.',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
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
        FilledButton(onPressed: _save, child: const Text('Create Study')),
      ],
    );
  }
}

class _UploadDocDialog extends StatefulWidget {
  const _UploadDocDialog();

  @override
  State<_UploadDocDialog> createState() => _UploadDocDialogState();
}

class _UploadDocDialogState extends State<_UploadDocDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Protocol Document'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Enter the protocol document filename (PDF). In production, the file will be uploaded to secure storage.',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Filename',
              hintText: 'e.g. Protocol_v1.0.pdf',
              suffixText: '.pdf',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = _ctrl.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(context).pop(
                  name.endsWith('.pdf') ? name : '$name.pdf');
            }
          },
          child: const Text('Confirm Upload'),
        ),
      ],
    );
  }
}
