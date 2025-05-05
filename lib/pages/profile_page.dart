import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print('Token tidak ditemukan.');
      return;
    }

    final apiService = ApiService(baseUrl: 'http://localhost:2020');

    final role = prefs.getString('role') ?? 'Parent';

    try {
      final profile = await apiService.fetchUserProfile(token, role);
      print('Profile data: $profile');

      setState(() {
        _isLoading = false;
        _profileData = profile;
      });
    } catch (e) {
      print('Gagal mengambil data profil: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(
                              'assets/avatar_placeholder.png',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _profileData?['full_name'] ?? 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _profileData?['email'] ?? 'Email tidak tersedia',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: [
                          ProfileDetailCard(
                            icon: Icons.lock,
                            title: 'Password',
                            subtitle: '********',
                          ),
                          ProfileDetailCard(
                            icon: Icons.person,
                            title: 'Login sebagai',
                            subtitle:
                                _profileData?['role'] ?? 'Role tidak tersedia',
                          ),
                          _profileData?['role'] == 'Child'
                              ? ProfileDetailCard(
                                icon: Icons.family_restroom,
                                title: 'Nama Parent',
                                subtitle:
                                    _profileData?['parent'] ??
                                    'Nama Parent tidak tersedia',
                              )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmation(context),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah kamu yakin ingin logout?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileDetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
