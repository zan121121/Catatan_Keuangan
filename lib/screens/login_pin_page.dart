import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'home_page.dart';

class LoginPinPage extends StatefulWidget {
  const LoginPinPage({super.key});

  @override
  State<LoginPinPage> createState() => _LoginPinPageState();
}

class _LoginPinPageState extends State<LoginPinPage> {
  final pinController = TextEditingController();
  String error = '';

  void _login() async {
    final db = await DBHelper.database;
    final result = await db.query('user');

    if (result.first['pin'] == pinController.text) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() {
        error = 'PIN salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan PIN',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('MASUK')),
          ],
        ),
      ),
    );
  }
}
