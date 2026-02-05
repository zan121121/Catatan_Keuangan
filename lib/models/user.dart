class User {
  final int? id;
  final String nama;
  final String pin;

  User({this.id, required this.nama, required this.pin});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama, 'pin': pin};
  }
}
