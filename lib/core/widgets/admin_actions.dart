import 'package:flutter/material.dart';
import 'package:training_courses_app/core/widgets/app_button.dart';

class AdminActions extends StatelessWidget {
  final VoidCallback onAddCourse;
  final VoidCallback onManageInstructors;
  final VoidCallback onRefresh;

  const AdminActions({
    super.key,
    required this.onAddCourse,
    required this.onManageInstructors,
    required this.onRefresh,
  });

  Widget _actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
  }) {
    return AppButton(
      text: text,
      icon: icon,
      onPressed: onTap,
      width: width,
      height: 54,
      type: AppButtonType.filled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth >= 560
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

        return Wrap(
          textDirection: TextDirection.rtl,
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionButton(
              text: 'إضافة دورة',
              icon: Icons.add_rounded,
              onTap: onAddCourse,
              width: itemWidth,
            ),
            _actionButton(
              text: 'إدارة المحاضرين',
              icon: Icons.groups_rounded,
              onTap: onManageInstructors,
              width: itemWidth,
            ),
            _actionButton(
              text: 'تحديث',
              icon: Icons.refresh_rounded,
              onTap: onRefresh,
              width: itemWidth,
            ),
          ],
        );
      },
    );
  }
}
