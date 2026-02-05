import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../database/db_helper.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int totalMasuk = 0;
  int totalKeluar = 0;

  Map<int, int> masukBulanan = {};
  Map<int, int> keluarBulanan = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DBHelper.database;
    final data = await db.query('transaksi');

    totalMasuk = 0;
    totalKeluar = 0;
    masukBulanan.clear();
    keluarBulanan.clear();

    for (var t in data) {
      final int jumlah = t['jumlah'] as int;
      final String jenis = t['jenis'].toString();
      final String tanggalStr = t['tanggal'].toString();

      if (tanggalStr.isEmpty) continue;
      final tanggal = DateTime.parse(tanggalStr);

      if (jenis == 'Masuk') {
        totalMasuk += jumlah;
        masukBulanan[tanggal.month] =
            (masukBulanan[tanggal.month] ?? 0) + jumlah;
      } else {
        totalKeluar += jumlah;
        keluarBulanan[tanggal.month] =
            (keluarBulanan[tanggal.month] ?? 0) + jumlah;
      }
    }

    setState(() {});
  }

  // ================= PDF =================
  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Laporan Keuangan',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Total Pemasukan : Rp $totalMasuk'),
            pw.Text('Total Pengeluaran : Rp $totalKeluar'),
            pw.Divider(),
            pw.Text(
              'Saldo : Rp ${totalMasuk - totalKeluar}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [_summaryCard(), const SizedBox(height: 24), _barChart()],
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Total Pemasukan'),
            trailing: Text(
              'Rp $totalMasuk',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Total Pengeluaran'),
            trailing: Text(
              'Rp $totalKeluar',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Saldo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              'Rp ${totalMasuk - totalKeluar}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BAR CHART =================
  Widget _barChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Grafik Keuangan per Bulan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  barGroups: List.generate(12, (index) {
                    final bulan = index + 1;
                    return BarChartGroupData(
                      x: index, // 🔥 PAKAI INDEX
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: (masukBulanan[bulan] ?? 0).toDouble(),
                          color: Colors.green,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: (keluarBulanan[bulan] ?? 0).toDouble(),
                          color: Colors.red,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, _) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            'Rp ${value ~/ 1000}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'B${value.toInt() + 1}', // 🔥 B1–B12 RAPI
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
