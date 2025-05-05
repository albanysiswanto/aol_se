import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lapar_fe/pages/child_dashboard.dart';
import 'package:lapar_fe/pages/register.dart';
import 'navigation/navigation_page.dart';
// import 'package:lapar_fe/pages/register.dart';
import '/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parenting App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/child_dashboard': (context) => ChildDashboard(),
      },
    );
  }
}
