import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class ResearchCentersScreen extends StatelessWidget {
  const ResearchCentersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Research Centers',
              subtitle:
                  '${data.researchCenters.length} registered research centers',
              action: FilledButton.icon(
                onPressed: () => _showDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Research Center'),
              ),
            ),
            const SizedBox(height: 24),
            if (data.researchCenters.isEmpty)
              const Center(child: Text('No research centers yet.'))
            else
              ...data.researchCenters.map((rc) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RCCard(rc: rc),
                  )),
          ],
        ),
    );
  }

  void _showDialog(BuildContext context, [ResearchCenter? existing]) {
    showDialog(
      context: context,
      builder: (_) => _RCDialog(existing: existing),
    );
  }
}

class _RCCard extends StatelessWidget {
  final ResearchCenter rc;
  const _RCCard({required this.rc});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final participants = data.participantsByRC(rc.id);
    final studies = data.studiesForRC(rc.id);
    final users = data.usersForRC(rc.id);
    final consented = participants
        .where((p) => p.consentStatus == ConsentStatus.consented)
        .length;
    final pending = participants
        .where((p) => p.consentStatus == ConsentStatus.pending)
        .length;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0F2F1),
                  child: const Icon(Icons.local_hospital,
                      color: Color(0xFF00695C)),
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
                          Text(rc.location,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _RCDialog(existing: rc),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmDialog(
                        title: 'Remove Research Center',
                        content:
                            'Remove "${rc.name}"? This will also remove associated users.',
                      ),
                    );
                    if (ok == true && context.mounted) {
                      context.read<DataProvider>().removeResearchCenter(rc.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(rc.contactEmail,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Chip('${participants.length} participants', Colors.purple),
                _Chip('${studies.length} studies', const Color(0xFF1565C0)),
                _Chip('$consented consented', const Color(0xFF2E7D32)),
                if (pending > 0)
                  _Chip('$pending pending', const Color(0xFFF57C00)),
              ],
            ),

            if (studies.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Assigned Studies',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              ...studies.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.science_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${s.title} (${s.phase})',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        StatusChip(
                            label: s.status.label, color: s.status.color),
                      ],
                    ),
                  )),
            ],

            if (users.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('RC Users',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              ...users.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('${u.name} · ${u.email}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )),
            ],

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _AddRCUserDialog(rcId: rc.id),
                ),
                icon: const Icon(Icons.person_add_outlined, size: 14),
                label: const Text('Add RC User', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _RCDialog extends StatefulWidget {
  final ResearchCenter? existing;
  const _RCDialog({this.existing});

  @override
  State<_RCDialog> createState() => _RCDialogState();
}

class _RCDialogState extends State<_RCDialog> {
  final _form = GlobalKey<FormState>();
  late final _nameCtrl =
      TextEditingController(text: widget.existing?.name);
  late final _locCtrl =
      TextEditingController(text: widget.existing?.location);
  late final _emailCtrl =
      TextEditingController(text: widget.existing?.contactEmail);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final data = context.read<DataProvider>();
    if (widget.existing != null) {
      data.updateResearchCenter(widget.existing!.id,
          name: _nameCtrl.text.trim(),
          location: _locCtrl.text.trim(),
          contactEmail: _emailCtrl.text.trim());
    } else {
      data.addResearchCenter(ResearchCenter(
        id: data.generateId(),
        name: _nameCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existing != null ? 'Edit Research Center' : 'Add Research Center'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Center Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _locCtrl,
                decoration:
                    const InputDecoration(labelText: 'Location (City, State)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Contact Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _AddRCUserDialog extends StatefulWidget {
  final String rcId;
  const _AddRCUserDialog({required this.rcId});

  @override
  State<_AddRCUserDialog> createState() => _AddRCUserDialogState();
}

class _AddRCUserDialogState extends State<_AddRCUserDialog> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final data = context.read<DataProvider>();
    data.addUser(User(
      id: data.generateId(),
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: UserRole.researchCenter,
      entityId: widget.rcId,
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('RC user account created.')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Research Center User'),
      content: SizedBox(
        width: 400,
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
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Initial Password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Min 6 characters' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Create')),
      ],
    );
  }
}
