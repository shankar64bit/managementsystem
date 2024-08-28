import 'package:flutter/material.dart';
import 'package:managementsystem/screens/assessment_creation.dart';
import 'package:managementsystem/screens/assessment_dashboard.dart';
import 'login_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String createAssessment = '/create-assessment';
  static const String takeAssessment = '/take-assessment';
  static const String userManagement = '/user-management';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginPage(),
      dashboard: (context) => AssessmentDashboard(),
      createAssessment: (context) => AssessmentCreationPage(),
      // takeAssessment: (context) => AssessmentDetailPage(),
      // userManagement: (context) => UserManagementPage(),
    };
  }
}
