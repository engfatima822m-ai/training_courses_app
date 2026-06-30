import 'package:flutter/material.dart';
import 'package:training_courses_app/models/course.dart';

class AdminCourseItem extends StatelessWidget {
  final Course course;
  final VoidCallback onDetails;
  final VoidCallback onViewRegistrants;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminCourseItem({
    super.key,
    required this.course,
    required this.onDetails,
    required this.onViewRegistrants,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color darkPurple = Color(0xFF2D033B);
  static const Color deepPurple = Color(0xFF4B0082);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year/$month/$day';
  }

  Color _statusColor() {
    if (course.isFull) return Colors.red;
    if (course.isRegistrationExpired) return Colors.grey.shade700;
    if (course.isEndingSoon) return Colors.orange.shade800;
    if (course.isRegistrationOpen) return Colors.green.shade700;
    return deepPurple;
  }

  IconData _statusIcon() {
    if (course.isFull) return Icons.event_busy_rounded;
    if (course.isRegistrationExpired) return Icons.lock_clock_rounded;
    if (course.isEndingSoon) return Icons.warning_amber_rounded;
    if (course.isRegistrationOpen) return Icons.check_circle_rounded;
    return Icons.info_rounded;
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 16, color: deepPurple),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text.isEmpty ? 'غير محدد' : text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: darkPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.55),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(_statusIcon(), size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            course.registrationStatusText,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seatInfoBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: darkPurple.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkPurple.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Icon(icon, color: deepPurple, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool filled,
    bool danger = false,
  }) {
    if (filled) {
      return SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: danger ? Colors.red : darkPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: danger ? Colors.red : deepPurple,
          side: BorderSide(color: danger ? Colors.red : deepPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth >= 520
            ? (constraints.maxWidth - 10) / 2
            : constraints.maxWidth;

        return Wrap(
          textDirection: TextDirection.rtl,
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: buttonWidth,
              child: _courseButton(
                text: 'تفاصيل الدورة',
                icon: Icons.info_outline_rounded,
                onPressed: onDetails,
                filled: true,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _courseButton(
                text: 'تعديل',
                icon: Icons.edit_rounded,
                onPressed: onEdit,
                filled: false,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _courseButton(
                text: 'مراقبة المسجلين',
                icon: Icons.groups_rounded,
                onPressed: onViewRegistrants,
                filled: false,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _courseButton(
                text: 'حذف',
                icon: Icons.delete_rounded,
                onPressed: onDelete,
                filled: false,
                danger: true,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = course.capacity == 0
        ? 0.0
        : (course.registeredCount / course.capacity).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: darkPurple.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            textDirection: TextDirection.rtl,
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.person_rounded, course.instructorsText),
              _chip(Icons.location_on_rounded, course.location),
              _chip(Icons.calendar_month_rounded, _formatDate(course.date)),
              _chip(Icons.access_time_rounded, course.time),
              _chip(
                Icons.play_circle_rounded,
                'التسجيل: ${_formatDate(course.registrationStartDate)}',
              ),
              _chip(
                Icons.stop_circle_rounded,
                'النهاية: ${_formatDate(course.registrationEndDate)}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _seatInfoBox(
                title: 'المقاعد',
                value: '${course.capacity}',
                icon: Icons.event_seat_rounded,
              ),
              const SizedBox(width: 10),
              _seatInfoBox(
                title: 'المسجلين',
                value: '${course.registeredCount}',
                icon: Icons.groups_rounded,
              ),
              const SizedBox(width: 10),
              _seatInfoBox(
                title: 'المتبقي',
                value: '${course.remainingSeats}',
                icon: Icons.how_to_reg_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: darkPurple.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                course.isFull ? Colors.red : deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildActionButtons(),
        ],
      ),
    );
  }
}
