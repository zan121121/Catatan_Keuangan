import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';
import 'tambah_transaksi_page.dart';
import 'laporan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int saldo = 0;
  int totalMasuk = 0;
  int totalKeluar = 0;
  List<Map<String, dynamic>> transaksi = [];

  // ================= LOAD DATA =================
  void _loadData() async {
    final db = await DBHelper.database;
    final data = await db.query('transaksi', orderBy: 'id DESC');

    int masuk = 0;
    int keluar = 0;

    for (var t in data) {
      final jumlah = t['jumlah'] as int;
      if (t['jenis'] == 'Masuk') {
        masuk += jumlah;
      } else {
        keluar += jumlah;
      }
    }

    setState(() {
      transaksi = data;
      totalMasuk = masuk;
      totalKeluar = keluar;
      saldo = masuk - keluar;
    });
  }

  // ================= HAPUS =================
  void _hapusTransaksi(int id) async {
    final db = await DBHelper.database;
    await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
    _loadData();
  }

  // ================= KONFIRMASI HAPUS =================
  void _showKonfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () {
              Navigator.pop(context);
              _hapusTransaksi(id);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DompetKu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LaporanPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahTransaksiPage()),
          );
          if (result == true) _loadData();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _saldoCard(),
            _pieChartCard(),
            _infoRingkas(),
            _listTransaksi(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= SALDO =================
  Widget _saldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo Saat Ini', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            'Rp $saldo',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PIE CHART =================
  Widget _pieChartCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Text(
              'Perbandingan Keuangan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 220,
                width: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 6,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: totalMasuk.toDouble(),
                        color: Colors.green,
                        title: 'Masuk',
                        radius: 70,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: totalKeluar.toDouble(),
                        color: Colors.red,
                        title: 'Keluar',
                        radius: 70,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INFO RINGKAS =================
  Widget _infoRingkas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Pemasukan'),
                subtitle: Text(
                  'Rp $totalMasuk',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Pengeluaran'),
                subtitle: Text(
                  'Rp $totalKeluar',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LIST TRANSAKSI =================
  Widget _listTransaksi() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transaksi.length,
      itemBuilder: (_, i) {
        final t = transaksi[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              t['jenis'] == 'Masuk' ? Icons.arrow_downward : Icons.arrow_upward,
              color: t['jenis'] == 'Masuk' ? Colors.green : Colors.red,
            ),
            title: Text(
              t['kategori'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(t['keterangan'] ?? '-'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${t['jenis'] == 'Masuk' ? '+' : '-'}${t['jumlah']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: t['jenis'] == 'Masuk' ? Colors.green : Colors.red,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TambahTransaksiPage(transaksi: t),
                        ),
                      );
                      if (result == true) _loadData();
                    } else {
                      _showKonfirmasiHapus(t['id']);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
