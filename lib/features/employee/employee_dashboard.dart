import 'package:flutter/material.dart';
import 'package:training_courses_app/core/theme/theme.dart';
import 'package:training_courses_app/models/user.dart';
import 'package:training_courses_app/screens/courses_list_screen.dart';
import 'package:training_courses_app/core/widgets/common/app_back_button.dart';

class EmployeeDashboard extends StatefulWidget {
  final User user;

  const EmployeeDashboard({
    super.key,
    required this.user,
  });

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  static const double sideBarWidth = 280;

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(child: _buildPageContent()),
            _buildSideBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return SafeArea(
      child: IndexedStack(
        index: selectedIndex,
        children: [
          _buildHomePage(),
          CoursesListScreen(
            user: widget.user,
            showAppBar: false,
          ),
          _buildMyRegistrationsPage(),
          _buildSettingsPage(),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionTitle(
          title: 'الخدمات المتاحة للموظف',
          icon: Icons.apps_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.menu_book_rounded,
                text: 'عرض الدورات التدريبية',
                onTap: () => setState(() => selectedIndex = 1),
              ),
            ),
            const SizedBox(width: AppSpacing.itemSpacing),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment_turned_in_rounded,
                text: 'تسجيلاتي',
                onTap: () => setState(() => selectedIndex = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionTitle(
          title: 'ملاحظات مهمة',
          icon: Icons.info_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoBox(
          icon: Icons.search_rounded,
          title: 'البحث والفلاتر',
          text: 'يمكنك البحث عن الدورة المناسبة حسب اسم الدورة أو المحاضر أو مكان الدورة أو الدرجة الوظيفية.',
        ),
        _buildInfoBox(
          icon: Icons.how_to_reg_rounded,
          title: 'التسجيل في الدورة',
          text: 'ادخلي إلى تفاصيل الدورة ثم أكملي بيانات التسجيل حسب النموذج المعتمد.',
        ),
      ],
    );
  }

  Widget _buildMyRegistrationsPage() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSmallPageHeader(
          title: 'تسجيلاتي',
          subtitle: 'سيتم عرض الدورات التي تم التسجيل بها هنا لاحقاً',
          icon: Icons.assignment_turned_in_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildInfoBox(
          icon: Icons.build_rounded,
          title: 'قيد التجهيز',
          text: 'هذه الصفحة مخصصة لاحقاً لعرض تسجيلات الموظف بعد ربطها بجدول التسجيلات.',
        ),
      ],
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSmallPageHeader(
          title: 'الإعدادات',
          subtitle: 'معلومات حساب الموظف',
          icon: Icons.settings_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildInfoCard(
          title: 'اسم الموظف',
          value: widget.user.fullName,
          icon: Icons.person_rounded,
        ),
        _buildInfoCard(
          title: 'الرقم الوظيفي',
          value: widget.user.employeeId,
          icon: Icons.badge_rounded,
        ),
        _buildInfoCard(
          title: 'الدرجة الوظيفية',
          value: widget.user.grade.toString(),
          icon: Icons.workspace_premium_rounded,
        ),
        _buildInfoCard(
          title: 'الصلاحية',
          value: 'موظف',
          icon: Icons.verified_user_rounded,
        ),
      ],
    );
  }

  Widget _buildSideBar() {
    return Container(
      width: sideBarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          left: BorderSide(
            color: AppColors.darkPurple.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 28,
                bottom: 28,
              ),
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
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AppBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 28),
                        Icon(
                          Icons.school_rounded,
                          color: AppColors.white,
                          size: 48,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'نظام الدورات التدريبية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'واجهة الموظف',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildMenuItem(
              index: 0,
              title: 'الرئيسية',
              icon: Icons.home_rounded,
            ),
            _buildMenuItem(
              index: 1,
              title: 'الدورات التدريبية',
              icon: Icons.menu_book_rounded,
            ),
            _buildMenuItem(
              index: 2,
              title: 'تسجيلاتي',
              icon: Icons.assignment_turned_in_rounded,
            ),
            _buildMenuItem(
              index: 3,
              title: 'الإعدادات',
              icon: Icons.settings_rounded,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                widget.user.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        onTap: () => setState(() => selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.deepPurple : Colors.grey.shade600,
                size: 25,
              ),
              const SizedBox(width: AppSpacing.itemSpacing),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.deepPurple : Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.darkPurple,
            AppColors.deepPurple,
            AppColors.softPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPurple.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.person_search_rounded,
              color: AppColors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'مرحباً ${widget.user.fullName}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'واجهة الموظف لمتابعة الدورات التدريبية والتسجيل بالدورات المناسبة',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPageHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.darkPurple,
            AppColors.deepPurple,
            AppColors.softPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: AppColors.white, size: 42),
          const SizedBox(width: AppSpacing.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: AppColors.darkPurple, size: 25),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.darkPurple,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPurple,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(color: AppColors.darkPurple.withOpacity(0.08)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.deepPurple, size: 30),
          const SizedBox(width: AppSpacing.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  text,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.largeRadius),
        border: Border.all(color: AppColors.darkPurple.withOpacity(0.08)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: AppColors.deepPurple, size: 28),
          const SizedBox(width: AppSpacing.itemSpacing),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
