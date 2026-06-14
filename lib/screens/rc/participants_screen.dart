import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final rcId = user.entityId ?? '';
    final data = context.watch<DataProvider>();
    final participants = data.participantsByRC(rcId);
    final studies = data.studiesForRC(rcId);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Participants'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Participants',
              subtitle: '${participants.length} participants at this center',
              action: FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _AddParticipantDialog(rcId: rcId),
                ),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add Participant'),
              ),
            ),
            const SizedBox(height: 24),

            if (participants.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('No participants yet.',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ...participants.map((p) {
                final study = p.assignedStudyId != null
                    ? data.getStudy(p.assignedStudyId!)
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                p.consentStatus.color.withOpacity(0.12),
                            child: Text(p.name[0],
                                style: TextStyle(
                                    color: p.consentStatus.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${p.name}, ${p.age}y ${p.gender}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(p.email,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                study != null
                                    ? Row(
                                        children: [
                                          const Icon(Icons.science_outlined,
                                              size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(study.title,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      )
                                    : const Text('No study assigned',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusChip(
                                  label: p.consentStatus.label,
                                  color: p.consentStatus.color),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (p.assignedStudyId == null &&
                                      studies.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(
                                          Icons.assignment_ind_outlined,
                                          size: 18),
                                      tooltip: 'Assign to study',
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (_) =>
                                            _AssignStudyDialog(
                                                participant: p,
                                                rcId: rcId),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                    tooltip: 'Remove participant',
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => ConfirmDialog(
                                          title: 'Remove Participant',
                                          content:
                                              'Remove ${p.name} from this research center?',
                                        ),
                                      );
                                      if (ok == true && context.mounted) {
                                        context
                                            .read<DataProvider>()
                                            .removeParticipant(p.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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

class _AddParticipantDialog extends StatefulWidget {
  final String rcId;
  const _AddParticipantDialog({required this.rcId});

  @override
  State<_AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<_AddParticipantDialog> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Male';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final data = context.read<DataProvider>();
    final id = data.generateId();
    data.addParticipant(Participant(
      id: id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      researchCenterId: widget.rcId,
      age: int.tryParse(_ageCtrl.text) ?? 0,
      gender: _gender,
    ));
    // Also add a participant user account
    data.addUser(User(
      id: '${id}_u',
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: 'participant123',
      role: UserRole.participant,
      entityId: id,
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participant added. Default password: participant123')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Participant'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other', 'Prefer not to say']
                          .map((g) =>
                              DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}

class _AssignStudyDialog extends StatefulWidget {
  final Participant participant;
  final String rcId;
  const _AssignStudyDialog({required this.participant, required this.rcId});

  @override
  State<_AssignStudyDialog> createState() => _AssignStudyDialogState();
}

class _AssignStudyDialogState extends State<_AssignStudyDialog> {
  String? _studyId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final studies = data.studiesForRC(widget.rcId);

    return AlertDialog(
      title: Text('Assign ${widget.participant.name} to Study'),
      content: studies.isEmpty
          ? const Text(
              'No studies are currently assigned to this research center.')
          : DropdownButtonFormField<String>(
              value: _studyId,
              decoration: const InputDecoration(labelText: 'Clinical Study'),
              items: studies
                  .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.title, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _studyId = v),
            ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        if (studies.isNotEmpty)
          FilledButton(
            onPressed: () {
              if (_studyId != null) {
                context
                    .read<DataProvider>()
                    .assignStudyToParticipant(widget.participant.id, _studyId!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Participant assigned to study.')));
              }
            },
            child: const Text('Assign'),
          ),
      ],
    );
  }
}
