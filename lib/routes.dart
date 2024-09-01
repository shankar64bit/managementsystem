import 'package:flutter/material.dart';
import 'package:managementsystem/screens/teachersView/assessment_creation.dart';
import 'package:managementsystem/screens/teachersView/assessment_dashboard.dart';
import 'screens/user/login_page.dart';
import 'screens/user/registration_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String createAssessment = '/create-assessment';
  static const String takeAssessment = '/take-assessment';
  static const String userManagement = '/user-management';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    register: (context) => RegistrationScreen(),
    dashboard: (context) => AssessmentDashboard(),
    createAssessment: (context) => AssessmentCreationPage(),
  };
}
