import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaController = TextEditingController();
  final pinController = TextEditingController();

  void _simpanUser() async {
    if (namaController.text.isEmpty || pinController.text.length != 4) {
      return;
    }

    final db = await DBHelper.database;
    await db.insert('user', {
      'nama': namaController.text,
      'pin': pinController.text,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN (4 digit)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _simpanUser,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SIMPAN AKUN'),
            ),
          ],
        ),
      ),
    );
  }
}
