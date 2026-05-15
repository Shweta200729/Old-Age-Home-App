import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/caretaker_provider.dart';
import 'providers/government_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/language_provider.dart';
import 'providers/relative_provider.dart';

import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/caretaker/caretaker_dashboard.dart';
import 'screens/government/government_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/relative/relative_dashboard.dart';
import 'core/supabase_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: App will crash on start if URL/Key aren't updated in this file. 
  // It's in a try-catch so it won't crash the whole app if keys aren't set yet properly.
  try {
    await SupabaseStorageService.initialize();
  } catch(e) {
    print('Supabase not initialized yet - configure your URL and Key');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CaretakerProvider()),
        ChangeNotifierProvider(create: (_) => GovernmentProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => RelativeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senior Care Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard/caretaker': (context) => const CaretakerDashboard(),
        '/dashboard/government': (context) => const GovernmentDashboard(),
        '/dashboard/admin': (context) => const AdminDashboard(),
        '/dashboard/relative': (context) => const RelativeDashboard(),
      },
    );
  }
}
