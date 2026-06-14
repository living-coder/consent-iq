import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static const _demoUsers = [
    {
      'name': 'Alice Johnson',
      'role': 'Administrator',
      'email': 'alice@consentiq.com',
      'password': 'admin123',
      'color': Color(0xFF6A1B9A),
      'icon': Icons.admin_panel_settings,
    },
    {
      'name': 'Carol Chen',
      'role': 'Clinical Study Sponsor',
      'email': 'carol@pharmax.com',
      'password': 'sponsor123',
      'color': Color(0xFF1565C0),
      'icon': Icons.business,
    },
    {
      'name': 'Dr. Emma Wilson',
      'role': 'Research Center',
      'email': 'emma@citymedical.com',
      'password': 'rc123',
      'color': Color(0xFF00695C),
      'icon': Icons.local_hospital,
    },
    {
      'name': 'Grace Kim',
      'role': 'Participant (Consented)',
      'email': 'grace@email.com',
      'password': 'patient123',
      'color': Color(0xFF2E7D32),
      'icon': Icons.verified_user,
    },
    {
      'name': 'Henry Liu',
      'role': 'Participant (Pending)',
      'email': 'henry@email.com',
      'password': 'patient123',
      'color': Color(0xFF2E7D32),
      'icon': Icons.person,
    },
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final success =
        context.read<AuthProvider>().login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!success && mounted) {
      setState(() {
        _loading = false;
        _error = 'Invalid email or password. Try the demo accounts below.';
      });
    }
  }

  void _quickLogin(String email, String password) {
    _emailCtrl.text = email;
    _passwordCtrl.text = password;
    _login();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Icon(Icons.verified_user_rounded,
                        size: 52, color: scheme.primary),
                    const SizedBox(height: 10),
                    Text('Consent IQ',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary)),
                    Text('Clinical Trial Consent Management',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 28),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                            onFieldSubmitted: (_) => _login(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_error!,
                                  style:
                                      TextStyle(color: scheme.onErrorContainer)),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('Sign In',
                                      style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Demo Quick Access',
                            style: TextStyle(
                                color: scheme.onSurfaceVariant, fontSize: 12)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 14),

                    ...(_demoUsers.map((u) {
                      final color = u['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () => _quickLogin(
                              u['email'] as String, u['password'] as String),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Row(
                            children: [
                              Icon(u['icon'] as IconData,
                                  color: color, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(u['name'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(u['role'] as String,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
