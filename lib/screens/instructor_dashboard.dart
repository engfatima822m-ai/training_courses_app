import 'package:flutter/material.dart';
import 'package:training_courses_app/models/user.dart';

class InstructorDashboard extends StatelessWidget {
  final User user;

  const InstructorDashboard({
    super.key,
    required this.user,
  });

  static const Color blackColor = Color(0xFF111111);
  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F2FA),
        appBar: AppBar(
          backgroundColor: blackColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'واجهة المحاضر',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            _buildSectionTitle('إحصائيات سريعة'),
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.menu_book_rounded,
                    title: 'الدورات',
                    value: '3',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.groups_rounded,
                    title: 'المسجلين',
                    value: '45',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.event_available_rounded,
                    title: 'القادمة',
                    value: '1',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('صلاحيات المحاضر'),
            const SizedBox(height: 12),
            _buildPermissionCard(
              Icons.visibility_rounded,
              'عرض الدورات المكلف بها',
            ),
            _buildPermissionCard(
              Icons.groups_rounded,
              'متابعة أعداد المسجلين',
            ),
            _buildPermissionCard(
              Icons.info_outline_rounded,
              'عرض تفاصيل الدورة التدريبية',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('الدورات المكلف بها'),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 520,
                child: Column(
                  children: [
                    _buildCourseCard(
                      title: 'إدارة المشاريع',
                      date: '2026/04/15',
                      registered: '12',
                    ),
                    _buildCourseCard(
                      title: 'السلامة المهنية',
                      date: '2026/04/20',
                      registered: '18',
                    ),
                    _buildCourseCard(
                      title: 'الأمن السيبراني',
                      date: '2026/05/02',
                      registered: '15',
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

  static Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            blackColor,
            darkPurple,
            blackColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'مرحباً بك في الصفحة الخاصة بالمحاضر',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لوحة المحاضر لمتابعة الدورات التدريبية',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: darkPurple,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 135,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkPurple,
            deepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPermissionCard(
    IconData icon,
    String text,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            color: deepPurple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCourseCard({
    required String title,
    required String date,
    required String registered,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 17,
              color: darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تاريخ الدورة: $date',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'عدد المسجلين: $registered',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text(
                'عرض التفاصيل',
                style: TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}