import 'package:flutter/material.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: QuizScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 1;
  int totalQuestions = 15;
  int selectedOption = -1;

  List<String> options = [
    'Surabaya',
    'Bandung',
    'Jakarta',
    'Medan',
  ];

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah kamu yakin sudah selesai menjawab kuis ini?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Ya, Selesai"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigasi ke hasil kuis atau halaman berikutnya bisa ditambahkan di sini
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Jawaban dikirim!")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLastQuestion = currentQuestion == totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Question Info & Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Soal $currentQuestion/$totalQuestions",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("00:30",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// Question Text
            Text(
              'Apa ibu kota Indonesia?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            /// Options
            ...List.generate(options.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedOption == index
                        ? Colors.deepPurple[100]
                        : Colors.white,
                    border: Border.all(
                        color: selectedOption == index
                            ? Colors.deepPurple
                            : Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedOption == index
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(options[index])),
                    ],
                  ),
                ),
              );
            }),

            Spacer(),

            /// Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentQuestion > 1
                      ? () {
                          setState(() {
                            currentQuestion--;
                            selectedOption = -1;
                          });
                        }
                      : null,
                  icon: Icon(Icons.arrow_back),
                  label: Text("Previous"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isLastQuestion) {
                      _showSubmitDialog();
                    } else {
                      setState(() {
                        currentQuestion++;
                        selectedOption = -1;
                      });
                    }
                  },
                  icon: Icon(isLastQuestion
                      ? Icons.check
                      : Icons.arrow_forward),
                  label: Text(isLastQuestion ? "Submit" : "Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
