import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import 'admin/admin_dashboard.dart';
import 'admin/sponsors_screen.dart';
import 'admin/research_centers_screen.dart';
import 'admin/admins_screen.dart';
import 'sponsor/sponsor_dashboard.dart';
import 'sponsor/studies_screen.dart';
import 'rc/rc_dashboard.dart';
import 'rc/participants_screen.dart';
import 'rc/studies_view_screen.dart';
import 'participant/participant_dashboard.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget Function() builder;

  const _NavItem(
      {required this.label, required this.icon, required this.builder});
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idx = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<_NavItem> _navFor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, builder: () => const AdminDashboard()),
          _NavItem(label: 'Sponsors', icon: Icons.business_outlined, builder: () => const SponsorsScreen()),
          _NavItem(label: 'Research Centers', icon: Icons.local_hospital_outlined, builder: () => const ResearchCentersScreen()),
          _NavItem(label: 'Administrators', icon: Icons.manage_accounts_outlined, builder: () => const AdminsScreen()),
        ];
      case UserRole.sponsor:
        return [
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, builder: () => const SponsorDashboard()),
          _NavItem(label: 'Clinical Studies', icon: Icons.science_outlined, builder: () => const StudiesScreen()),
        ];
      case UserRole.researchCenter:
        return [
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, builder: () => const RCDashboard()),
          _NavItem(label: 'Participants', icon: Icons.people_outlined, builder: () => const ParticipantsScreen()),
          _NavItem(label: 'Clinical Studies', icon: Icons.science_outlined, builder: () => const StudiesViewScreen()),
        ];
      case UserRole.participant:
        return [
          _NavItem(label: 'My Study & Consent', icon: Icons.assignment_outlined, builder: () => const ParticipantDashboard()),
        ];
    }
  }

  Widget _buildNavItems(BuildContext context, List<_NavItem> nav, int safeIdx,
      {bool inDrawer = false}) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      itemCount: nav.length,
      itemBuilder: (ctx, i) {
        final selected = i == safeIdx;
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: ListTile(
            leading: Icon(nav[i].icon,
                size: 20,
                color: selected ? scheme.primary : scheme.onSurfaceVariant),
            title: Text(nav[i].label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? scheme.primary : scheme.onSurface)),
            selected: selected,
            selectedTileColor: scheme.primaryContainer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            dense: true,
            onTap: () {
              setState(() => _idx = i);
              if (inDrawer) Navigator.of(ctx).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildSideContent(BuildContext context, List<_NavItem> nav,
      int safeIdx, User user, AuthProvider auth,
      {bool inDrawer = false}) {
    final scheme = Theme.of(context).colorScheme;
    final roleColor = user.role.color;
    return Column(
      children: [
        // Logo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Icon(Icons.verified_user_rounded,
                  color: scheme.primary, size: 26),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consent IQ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: scheme.primary)),
                  Text('Clinical Trials',
                      style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),

        // Role badge
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(user.role.icon, color: roleColor, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(user.role.label,
                      style: TextStyle(
                          fontSize: 11,
                          color: roleColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Nav items
        Expanded(
            child: _buildNavItems(context, nav, safeIdx,
                inDrawer: inDrawer)),

        // User footer
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: roleColor.withOpacity(0.15),
                    child: Text(user.name[0],
                        style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                        Text(user.email,
                            style: TextStyle(
                                fontSize: 10,
                                color: scheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _idx = 0);
                    auth.logout();
                  },
                  icon: const Icon(Icons.logout, size: 14),
                  label: const Text('Sign Out',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final nav = _navFor(user.role);
    final safeIdx = _idx.clamp(0, nav.length - 1);
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 640;

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: scheme.surface,
          elevation: 1,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Row(
            children: [
              Icon(Icons.verified_user_rounded,
                  color: scheme.primary, size: 20),
              const SizedBox(width: 6),
              Text('Consent IQ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: scheme.primary)),
            ],
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: _buildSideContent(context, nav, safeIdx, user, auth,
                inDrawer: true),
          ),
        ),
        body: nav[safeIdx].builder(),
      );
    }

    // Desktop: persistent sidebar
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 224,
            color: scheme.surface,
            child: _buildSideContent(context, nav, safeIdx, user, auth),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: nav[safeIdx].builder()),
        ],
      ),
    );
  }
}
