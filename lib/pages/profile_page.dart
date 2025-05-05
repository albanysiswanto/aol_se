import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar and Name Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/image/hatta.png',
                    ), // Replace with your asset
                  ),
                  SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'johndoe@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Profile Details Section
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
                    subtitle: 'Child',
                  ),
                  ProfileDetailCard(
                    icon: Icons.school,
                    title: 'Tingkat Sekolah',
                    subtitle: 'SMA',
                  ),
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
      builder:
          (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Apakah Anda yakin ingin logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.pop(context); // Tutup dialog
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginPage()),
                  // );
                },
                child: const Text("Logout"),
              ),
            ],
          ),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileDetailCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
