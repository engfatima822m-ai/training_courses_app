import 'package:flutter/material.dart';
import 'package:training_courses_app/services/data_service.dart';
import 'package:training_courses_app/screens/splash_screen.dart';
import 'package:training_courses_app/core/theme/app_colors.dart';

/// ==============================
/// بداية تشغيل التطبيق
/// ==============================
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ لا ننتظر تحميل البيانات هنا
  runApp(const TrainingCoursesApp());
}

class TrainingCoursesApp extends StatefulWidget {
  const TrainingCoursesApp({super.key});

  @override
  State<TrainingCoursesApp> createState() => _TrainingCoursesAppState();
}

class _TrainingCoursesAppState extends State<TrainingCoursesApp> {
  @override
  void initState() {
    super.initState();

    // ✅ تحميل البيانات بالخلفية بدون تجميد التطبيق
    DataService.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قسم الموارد البشرية / شعبة التدريب والتطوير',
      debugShowCheckedModeBanner: false,

      // ⭐ الثيم العام للتطبيق
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}