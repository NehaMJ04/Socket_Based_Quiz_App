
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFFE5B6D1),
      fontFamily: 'Roboto',
    ),
    home: QuizFlow(),
  ),
);

class QuizFlow extends StatefulWidget {
  @override
  _QuizFlowState createState() => _QuizFlowState();
}

class _QuizFlowState extends State<QuizFlow> {
  final String serverIP = "10.152.242.76";
  final int serverPort = 5050;

  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _score = 0;
  String _serverResponse = "Waiting for server...";
  bool _isSending = false;

  // UPDATED: MCQ QUESTION DATA 
  final List<Map<String, dynamic>> _questions = [
    {
      "q": "What is the capital of India?",
      "options": ["Mumbai", "New Delhi", "Kolkata", "Chennai"],
      "a": "New Delhi",
    },
    {
      "q": "Which type of programming does Python support?",
      "options": [
        "Functional",
        "Object-Oriented",
        "Procedural",
        "All of the above",
      ],
      "a": "All of the above",
    },
    {
      "q": "What is the full form of CPU?",
      "options": [
        "Central Process Unit",
        "Central Processing Unit",
        "Computer Port Unit",
        "Core Processing Unit",
      ],
      "a": "Central Processing Unit",
    },
  ];

  // --- UPDATED: DARKER BACKGROUND ---
  BoxDecoration _scaffoldGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A0E21), Color(0xFF1A1F3C)], // Very dark navy blue
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _submitFinalScore() async {
    setState(() => _isSending = true);
    _nextPage();

    try {
      Socket socket = await Socket.connect(
        serverIP,
        serverPort,
        timeout: const Duration(seconds: 5),
      );
     Map<String, dynamic> data = {
      "name": _nameController.text,
      "score": _score,
      "timestamp": DateTime.now().toIso8601String(),
      };


      socket.write(jsonEncode(data));
      socket.listen((List<int> event) {
        setState(() {
          _serverResponse = utf8.decode(event);
          _isSending = false;
        });
        socket.close();

      });
    } catch (e) {
      setState(() {
        _serverResponse = "Connection Failed: Check Server";
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _scaffoldGradient(),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSplash(),
            _buildLogin(),
            ..._questions.map((q) => _buildQuizPage(q)).toList(),
            _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildSplash() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.rocket_launch_rounded,
          size: 100,
          color: Color(0xFFE5B6D1),
        ), // Pastel
        const SizedBox(height: 20),
        const Text(
          "QUIZ MASTER",
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 60),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE5B6D1), // Pastel Pink/Lavender
            foregroundColor: const Color(0xFF1A1F3C),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          onPressed: _nextPage,
          child: const Text(
            "GET STARTED",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLogin() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), // Dark card
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Registration",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Student Name",
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5B6D1)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5B6D1),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (_nameController.text.trim().isNotEmpty) _nextPage();
                },
                child: const Text("ENTER QUIZ"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED: MCQ QUIZ PAGE ---
  Widget _buildQuizPage(Map<String, dynamic> questionData) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "QUESTION",
              style: TextStyle(
                letterSpacing: 2,
                color: Color(0xFFE5B6D1),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white10, thickness: 1),
            const SizedBox(height: 20),
            Text(
              questionData['q'],
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Build MCQ Options
            ...List.generate(questionData['options'].length, (index) {
              String option = questionData['options'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (option == questionData['a']) _score++;
                      if (_pageController.page!.toInt() ==
                          _questions.length + 1) {
                        _submitFinalScore();
                      } else {
                        _nextPage();
                      }
                    },
                    child: Text(
                      option,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isSending
              ? const CircularProgressIndicator(color: Color(0xFFE5B6D1))
              : const Icon(Icons.stars, size: 100, color: Color(0xFFE5B6D1)),
          const SizedBox(height: 30),
          const Text(
            "Quiz Finished!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Score: $_score / ${_questions.length}",
            style: const TextStyle(color: Colors.white70, fontSize: 20),
          ),
          const SizedBox(height: 40),
          Text(
            _serverResponse,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => QuizFlow()),
            ),
            child: const Text(
              "RESTART",
              style: TextStyle(color: Color(0xFFE5B6D1)),
            ),
          ),
        ],
      ),
    );
  }
}
