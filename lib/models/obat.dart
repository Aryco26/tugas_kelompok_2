import 'package:intl/intl.dart';

class Obat {
  // membuat variable yang akan tersambung dengan field di database
  String? id_obat;
  String? nama;
  String? deskripsi;
  int? harga;
  int? stok;
  DateTime? kadaluarsa;

  // membuat array obat yang digunakan untuk menyimpan data json yang diambil dari database melalui api php
  Obat(
      {this.id_obat,
      this.nama,
      this.deskripsi,
      this.harga,
      this.stok,
      this.kadaluarsa});

  // mengambil data dari json
  factory Obat.fromJson(Map<String, dynamic> json) => Obat(
        id_obat: json['id_obat'],
        nama: json['nama'],
        deskripsi: json['deskripsi'],
        harga: json['harga'],
        stok: json['stok'],
        kadaluarsa: json['kadaluarsa'] != null
            ? DateTime.tryParse(json['kadaluarsa'])
            : null,
      );
  // mengirim data ke json
  Map<String, dynamic> toJson() => {
        'id_obat': id_obat,
        'nama': nama,
        'deskripsi': deskripsi,
        'harga': harga,
        'stok': stok,
        'kadaluarsa': kadaluarsa != null
            ? DateFormat('yyyy-MM-dd').format(kadaluarsa!)
            : null,
      };
}
