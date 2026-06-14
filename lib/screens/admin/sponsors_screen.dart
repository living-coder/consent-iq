import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class SponsorsScreen extends StatelessWidget {
  const SponsorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Clinical Study Sponsors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Sponsors',
              subtitle: '${data.sponsors.length} registered sponsor organisations',
              action: FilledButton.icon(
                onPressed: () => _showSponsorDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Sponsor'),
              ),
            ),
            const SizedBox(height: 24),
            if (data.sponsors.isEmpty)
              const Center(child: Text('No sponsors yet.'))
            else
              ...data.sponsors.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SponsorCard(sponsor: s),
                  )),
          ],
        ),
      ),
    );
  }

  void _showSponsorDialog(BuildContext context, [ClinicalStudySponsor? existing]) {
    showDialog(
      context: context,
      builder: (_) => _SponsorDialog(existing: existing),
    );
  }
}

class _SponsorCard extends StatelessWidget {
  final ClinicalStudySponsor sponsor;
  const _SponsorCard({required this.sponsor});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final studies = data.studiesBySponsor(sponsor.id);
    final users = data.usersForSponsor(sponsor.id);

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
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: const Icon(Icons.business, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sponsor.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(sponsor.contactEmail,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _SponsorDialog(existing: sponsor),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmDialog(
                        title: 'Remove Sponsor',
                        content:
                            'Remove "${sponsor.name}"? This will also remove all associated users.',
                      ),
                    );
                    if (ok == true && context.mounted) {
                      context.read<DataProvider>().removeSponsor(sponsor.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(sponsor.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 14),
            Row(
              children: [
                _Pill(label: '${studies.length} studies', color: const Color(0xFF1565C0)),
                const SizedBox(width: 8),
                _Pill(label: '${users.length} users', color: const Color(0xFF6A1B9A)),
              ],
            ),
            if (users.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Sponsor Users',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              ...users.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14,
                            color: Colors.grey),
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
                  builder: (_) => _AddUserDialog(
                      entityId: sponsor.id, role: UserRole.sponsor),
                ),
                icon: const Icon(Icons.person_add_outlined, size: 14),
                label: const Text('Add Sponsor User',
                    style: TextStyle(fontSize: 12)),
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

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

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

class _SponsorDialog extends StatefulWidget {
  final ClinicalStudySponsor? existing;
  const _SponsorDialog({this.existing});

  @override
  State<_SponsorDialog> createState() => _SponsorDialogState();
}

class _SponsorDialogState extends State<_SponsorDialog> {
  final _form = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _emailCtrl =
      TextEditingController(text: widget.existing?.contactEmail);
  late final _descCtrl =
      TextEditingController(text: widget.existing?.description);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final data = context.read<DataProvider>();
    if (widget.existing != null) {
      data.updateSponsor(widget.existing!.id,
          name: _nameCtrl.text.trim(),
          contactEmail: _emailCtrl.text.trim(),
          description: _descCtrl.text.trim());
    } else {
      data.addSponsor(ClinicalStudySponsor(
        id: data.generateId(),
        name: _nameCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing != null ? 'Edit Sponsor' : 'Add Sponsor'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Organisation Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Contact Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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

class _AddUserDialog extends StatefulWidget {
  final String entityId;
  final UserRole role;
  const _AddUserDialog({required this.entityId, required this.role});

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
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
      role: widget.role,
      entityId: widget.entityId,
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User account created.')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Sponsor User Account'),
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
