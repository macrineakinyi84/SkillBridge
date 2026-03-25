import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../core/router/app_router.dart' as router;

// Shell for main tabs so each branch keeps its own nav stack (StatefulShellRoute
// in app_router.dart); bottom bar reflects path via _selectedIndexForPath.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static int _selectedIndexForPath(String path) {
    if (path.startsWith(router.AppRouter.dashboard)) return 0;
    if (path.startsWith(router.AppRouter.skills)) return 1;
    if (path.startsWith(router.AppRouter.portfolio)) return 2;
    if (path.startsWith(router.AppRouter.profile)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) => navigationShell.goBranch(index);

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
                _NavItem(icon: Icons.dashboard_rounded, label: 'Home', isSelected: selectedIndex == 0, isDark: isDark, onTap: () => _onTap(context, 0)),
                _NavItem(icon: Icons.psychology_rounded, label: 'Skills', isSelected: selectedIndex == 1, isDark: isDark, onTap: () => _onTap(context, 1)),
                _NavItem(icon: Icons.folder_special_rounded, label: 'Portfolio', isSelected: selectedIndex == 2, isDark: isDark, onTap: () => _onTap(context, 2)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: color)),
          ],
        ),
      ),
    );
  }
}
