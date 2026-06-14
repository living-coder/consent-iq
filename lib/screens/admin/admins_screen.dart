import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

class AdminsScreen extends StatelessWidget {
  const AdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser!.id;
    final admins = data.adminUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Administrators'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Administrators',
              subtitle: '${admins.length} administrator accounts',
              action: FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const _AddAdminDialog(),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Administrator'),
              ),
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Administrator Accounts',
              icon: Icons.admin_panel_settings_outlined,
              children: admins
                  .map((u) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFF6A1B9A).withOpacity(0.12),
                          child: Text(u.name[0],
                              style: const TextStyle(
                                  color: Color(0xFF6A1B9A),
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Row(
                          children: [
                            Text(u.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            if (u.id == currentUserId) ...[
                              const SizedBox(width: 8),
                              const StatusChip(
                                  label: 'You',
                                  color: Color(0xFF1565C0)),
                            ],
                          ],
                        ),
                        subtitle: Text(u.email),
                        trailing: u.id == currentUserId
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                tooltip: 'Remove admin',
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => ConfirmDialog(
                                      title: 'Remove Administrator',
                                      content:
                                          'Remove "${u.name}" as an administrator?',
                                    ),
                                  );
                                  if (ok == true && context.mounted) {
                                    context
                                        .read<DataProvider>()
                                        .removeUser(u.id);
                                  }
                                },
                              ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFFE082))),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outlined, color: Color(0xFFF57C00)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Administrators have full access to all system entities including sponsors, research centers, users, and clinical studies. Grant this role carefully.',
                        style: TextStyle(color: Color(0xFF5D4037), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAdminDialog extends StatefulWidget {
  const _AddAdminDialog();

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
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
      role: UserRole.admin,
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Administrator account created.')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Administrator'),
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
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Initial Password'),
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
