import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../core/router/app_router.dart' as router;

/// Employer-only shell: Dashboard, Listings, Talent pool, Profile.
/// Students must never see this; use role-based redirect so only employers reach /employer/*.
class EmployerShell extends StatelessWidget {
  const EmployerShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static int _selectedIndexForPath(String path) {
    if (path.startsWith(router.AppRouter.employerDashboard)) return 0;
    if (path.startsWith('/employer/listings') && !path.contains('/edit/') && !path.contains('/candidates/')) return 1;
    if (path.startsWith('/employer/talent-pool')) return 2;
    if (path.startsWith('/employer/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(router.AppRouter.employerDashboard);
        break;
      case 1:
        context.go(router.AppRouter.employerListings);
        break;
      case 2:
        context.go('/employer/talent-pool');
        break;
      case 3:
        context.go('/employer/profile');
        break;
      default:
        navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForPath(path);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', isSelected: selectedIndex == 0, isDark: isDark, onTap: () => _onTap(context, 0)),
                _NavItem(icon: Icons.work_rounded, label: 'Listings', isSelected: selectedIndex == 1, isDark: isDark, onTap: () => _onTap(context, 1)),
                _NavItem(icon: Icons.people_rounded, label: 'Talent', isSelected: selectedIndex == 2, isDark: isDark, onTap: () => _onTap(context, 2)),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', isSelected: selectedIndex == 3, isDark: isDark, onTap: () => _onTap(context, 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.isDark, required this.onTap});
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: color)),
          ],
        ),
      ),
    );
  }
}
