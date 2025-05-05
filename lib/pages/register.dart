import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/register_request.dart';
import 'package:lapar_fe/pages/login.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/widget_popup.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

//penting
class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final passwordController = TextEditingController();
  final inviteTokenController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final api = ApiService(baseUrl: 'http://localhost:2020');
    final request = RegisterRequest(
      full_name: fullNameController.text.trim(),
      email: emailController.text.trim(),
      birth_date: birthDateController.text.trim(),
      password: passwordController.text,
      invite_token:
          inviteTokenController.text.isNotEmpty
              ? inviteTokenController.text
              : null,
    );

    try {
      await api.registerUser(request);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!')));
      // Arahkan ke halaman lain jika perlu
    } catch (e) {
      setState(() {
        errorMessage = "Email sudah terdaftar atau password tidak boleh kosong";
      });
      showErrorPopup(context, errorMessage!);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    passwordController.dispose();
    inviteTokenController.dispose();
    super.dispose();
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Padding(
        
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: fullNameController,
//               decoration: const InputDecoration(labelText: 'Full Name'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: birthDateController,
//               decoration: const InputDecoration(
//                 labelText: 'Birth Date (YYYY-MM-DD)',
//               ),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             TextField(
//               controller: inviteTokenController,
//               decoration: const InputDecoration(
//                 labelText: 'Invite Token (optional)',
//               ),
//             ),
//             const SizedBox(height: 16),
//             isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                   onPressed: register,
//                   child: const Text('Register'),
//                 ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LoginPage()),
//                 );
//               },
//               child: const Text('Sudah punya akun? Login di sini'),
//             ),
//             if (errorMessage != null) ...[
//               const SizedBox(height: 12),
//               Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // const FlutterLogo(size: 80),
              Image.asset('assets/lapar.png', width: 120, height: 120),
              const SizedBox(height: 16),
              Text(
                "Create Account",
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Register to start using the app",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              _buildLabel("Full Name"),
              _buildTextField(fullNameController, "Enter your full name"),

              const SizedBox(height: 16),
              _buildLabel("Email"),
              _buildTextField(emailController, "Enter your email", keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 16),
              _buildLabel("Birth Date"),
              _buildTextField(birthDateController, "YYYY-MM-DD"),

              const SizedBox(height: 16),
              _buildLabel("Password"),
              _buildTextField(passwordController, "Enter your password", obscureText: true),

              const SizedBox(height: 16),
              _buildLabel("Invite Token (optional)"),
              _buildTextField(inviteTokenController, "Enter your invite token (optional)"),

              const SizedBox(height: 16),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Register",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                child: Text(
                  "Sudah punya akun? Login di sini",
                  style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                ),
              ),
              // if (errorMessage != null) ...[
              //   const SizedBox(height: 12),
              //   Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
