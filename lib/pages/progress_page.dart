import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Pengerjaan Soal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Progress Bar Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.7, // 70% selesai
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '70% selesai',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Details Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  'Soal yang telah dikerjakan:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '10 dari 15 soal',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Additional Info Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(Icons.info, color: Colors.blueAccent),
                title: Text(
                  'Sisa Soal:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '5 soal lagi untuk diselesaikan',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}