import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../widgets/custom_button.dart';

class TambahTransaksiPage extends StatefulWidget {
  final Map<String, dynamic>? transaksi; // ← untuk EDIT

  const TambahTransaksiPage({super.key, this.transaksi});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  String jenis = 'Masuk';
  final kategoriController = TextEditingController();
  final jumlahController = TextEditingController();
  final ketController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();

    // ===== MODE EDIT =====
    if (widget.transaksi != null) {
      isEdit = true;
      jenis = widget.transaksi!['jenis'];
      kategoriController.text = widget.transaksi!['kategori'];
      jumlahController.text = widget.transaksi!['jumlah'].toString();
      ketController.text = widget.transaksi!['keterangan'] ?? '';
    }
  }

  // ================= SIMPAN / UPDATE =================
  void _simpan() async {
    final db = await DBHelper.database;

    if (kategoriController.text.isEmpty || jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data belum lengkap')));
      return;
    }

    if (isEdit) {
      // ===== UPDATE =====
      await db.update(
        'transaksi',
        {
          'jenis': jenis,
          'kategori': kategoriController.text,
          'jumlah': int.parse(jumlahController.text),
          'keterangan': ketController.text,
        },
        where: 'id = ?',
        whereArgs: [widget.transaksi!['id']],
      );
    } else {
      // ===== INSERT =====
      await db.insert('transaksi', {
        'jenis': jenis,
        'kategori': kategoriController.text,
        'jumlah': int.parse(jumlahController.text),
        'tanggal': DateTime.now().toIso8601String(),
        'keterangan': ketController.text,
      });
    }

    Navigator.pop(context, true); // balik ke Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ===== JENIS =====
            DropdownButtonFormField(
              value: jenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Transaksi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Masuk', child: Text('Pemasukan')),
                DropdownMenuItem(value: 'Keluar', child: Text('Pengeluaran')),
              ],
              onChanged: (value) => setState(() => jenis = value!),
            ),

            const SizedBox(height: 16),

            // ===== KATEGORI =====
            TextField(
              controller: kategoriController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ===== JUMLAH =====
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ===== KETERANGAN =====
            TextField(
              controller: ketController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ===== BUTTON =====
            CustomButton(
              text: isEdit ? 'UPDATE' : 'SIMPAN',
              onPressed: _simpan,
            ),
          ],
        ),
      ),
    );
  }
}
