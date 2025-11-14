// screens/common/role_based_navigator.dart
import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/auth/login_screen.dart';
import 'package:keep_it_grow/screens/parent/parent_dashboard_screen.dart';
import 'package:keep_it_grow/screens/student/student_dashboard.dart';
import 'package:keep_it_grow/screens/teacher/teacher_dashboard.dart';
import '../auth/login_screen.dart';
// import '../student/student_dashboard.dart';
// import '../teacher/teacher_dashboard.dart';
// import '../parent/parent_dashboard.dart';
import '../../../models/user_model.dart';

class RoleBasedNavigator extends StatelessWidget {
  final UserModel user;

  const RoleBasedNavigator({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (user.role.toLowerCase()) {
      case 'siswa':
      case 'student':
        return StudentDashboard(user: user);
      case 'guru':
      case 'teacher':
        return TeacherDashboard(user: user);
      case 'ortu':
      case 'parent':
        return ParentDashboardScreen(user: user,);
      default:
        // Fallback ke login jika role tidak dikenali
        return LoginPage();
    }
  }
}