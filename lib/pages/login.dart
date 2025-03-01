import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        final profile =
            await Supabase.instance.client
                .from('profiles')
                .select('role')
                .eq('id', response.user!.id)
                .single();

        if (profile['role'] == 'Parent') {
          context.go('/parent_dashboard');
        } else {
          context.go('/child_dashboard');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                  children: [
                    ElevatedButton(onPressed: _login, child: Text('Login')),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: Text('Belum punya akun? Register di sini'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        context.go('/register_child?invite=dummy_code_1234');
                      },
                      child: Text('Belum punya akun? Register di sini anak'),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
