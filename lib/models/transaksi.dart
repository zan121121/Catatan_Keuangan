class Transaksi {
  final int? id;
  final String jenis;
  final String kategori;
  final int jumlah;
  final String tanggal;
  final String keterangan;

  Transaksi({
    this.id,
    required this.jenis,
    required this.kategori,
    required this.jumlah,
    required this.tanggal,
    required this.keterangan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'kategori': kategori,
      'jumlah': jumlah,
      'tanggal': tanggal,
      'keterangan': keterangan,
    };
  }
}
