import 'package:flutter/material.dart';
import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/core/widgets/common/app_back_button.dart';

class DashboardShell extends StatelessWidget {
  final String title;
  final Widget child;
  final int selectedIndex;
  final void Function(int index)? onMenuTap;
  final VoidCallback? onLogout;

  const DashboardShell({
    super.key,
    required this.title,
    required this.child,
    this.selectedIndex = 0,
    this.onMenuTap,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 850;

          return Scaffold(
            backgroundColor: AppColors.background,

            // على الهاتف تظهر قائمة قابلة للفتح.
            drawer: isMobile
                ? Drawer(
                    width: 290,
                    backgroundColor: AppColors.white,
                    child: _buildSidebar(
                      context,
                      closeDrawerAfterTap: true,
                      showBackButton: false,
                    ),
                  )
                : null,

            // شريط علوي خاص بالهاتف.
            appBar: isMobile
                ? AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColors.deepPurple,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    titleSpacing: 0,
                    leading: Builder(
                      builder: (scaffoldContext) {
                        return IconButton(
                          tooltip: 'فتح القائمة',
                          icon: const Icon(
                            Icons.menu_rounded,
                            size: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(scaffoldContext).openDrawer();
                          },
                        );
                      },
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'رجوع',
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                    ],
                  )
                : null,

            body: isMobile
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: child,
                  )
                : Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppSpacing.pagePadding,
                          ),
                          child: child,
                        ),
                      ),
                      SizedBox(
                        width: 290,
                        child: _buildSidebar(
                          context,
                          closeDrawerAfterTap: false,
                          showBackButton: true,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context, {
    required bool closeDrawerAfterTap,
    required bool showBackButton,
  }) {
    void handleMenuTap(int index) {
      if (closeDrawerAfterTap) {
        Navigator.pop(context);
      }

      onMenuTap?.call(index);
    }

    void handleLogout() {
      if (closeDrawerAfterTap) {
        Navigator.pop(context);
      }

      onLogout?.call();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          left: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.deepPurple,
                  AppColors.softPurple,
                ],
              ),
            ),
            child: Stack(
              children: [
                if (showBackButton)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: AppBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    top: showBackButton ? 30 : 10,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        color: AppColors.white,
                        size: 54,
                      ),
                      const SizedBox(height: AppSpacing.itemSpacing),
                      const Text(
                        'نظام الدورات التدريبية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.home_rounded,
                    label: 'الرئيسية',
                    selected: selectedIndex == 0,
                    onTap: () => handleMenuTap(0),
                  ),
                  _MenuItem(
                    icon: Icons.menu_book_rounded,
                    label: 'الدورات التدريبية',
                    selected: selectedIndex == 1,
                    onTap: () => handleMenuTap(1),
                  ),
                  _MenuItem(
                    icon: Icons.groups_rounded,
                    label: 'المسجلون',
                    selected: selectedIndex == 2,
                    onTap: () => handleMenuTap(2),
                  ),
                  _MenuItem(
                    icon: Icons.person_rounded,
                    label: 'المحاضرون',
                    selected: selectedIndex == 3,
                    onTap: () => handleMenuTap(3),
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'التقارير',
                    selected: selectedIndex == 4,
                    onTap: () => handleMenuTap(4),
                  ),
                  _MenuItem(
                    icon: Icons.settings_rounded,
                    label: 'الإعدادات',
                    selected: selectedIndex == 5,
                    onTap: () => handleMenuTap(5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'تسجيل الخروج',
                    danger: true,
                    onTap: handleLogout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool danger;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = danger
        ? AppColors.danger
        : selected
            ? AppColors.deepPurple
            : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.lightPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: ListTile(
        onTap: onTap,
        minLeadingWidth: 26,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: selected ? FontWeight.bold : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}