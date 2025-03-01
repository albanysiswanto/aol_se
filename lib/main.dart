import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/register_child.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ftqqwhdqkjyclvntgbvr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cXF3aGRxa2p5Y2x2bnRnYnZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4MTUzNDEsImV4cCI6MjA1NjM5MTM0MX0.03QUK_CvYV1i4gozU44cv1FN68Bc189d32yQiKlZSVM',
  );

  runApp(MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) => MyApp(),
    // ),
    GoRoute(path: '/', builder: (context, state) => LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
    GoRoute(
      path: '/register_child',
      builder: (context, state) {
        final inviteCode =
            state.uri.queryParameters['invite'] ??
            'dummy_code_1234'; // Gunakan dummy jika tidak ada
        return RegisterChildPage(inviteCode: inviteCode);
      },
    ),
    // GoRoute(
    //   path: '/parent_dashboard',
    //   builder: (context, state) => ParentDashboard(),
    // ),
    // GoRoute(
    //   path: '/child_dashboard',
    //   builder: (context, state) => ChildDashboard(),
    // ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parent Control App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router, // Gunakan go_router untuk navigasi
    );
  }
}
