import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CrudObat extends StatefulWidget {
  final Map<String, dynamic>? dataObat;
  const CrudObat({Key? key, this.dataObat}) : super(key: key);
  @override
  CrudObatState createState() => CrudObatState();
}

class CrudObatState extends State<CrudObat> {
  String status = "";
  bool isLoading = false;
  final dateFormat = DateFormat('yyyy-MM-dd');
  final idObatController = TextEditingController();
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final stokController = TextEditingController();
  final hargaController = TextEditingController();
  final kadaluarsaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.dataObat != null) {
      status = "Edit Data Obat";
      idObatController.text = widget.dataObat?['id_obat'] ?? '';
      namaController.text = widget.dataObat?['nama'] ?? '';
      deskripsiController.text = widget.dataObat?['deskripsi'] ?? '';
      hargaController.text = widget.dataObat?['harga'].toString() ?? '';
      stokController.text = widget.dataObat?['stok'].toString() ?? '';
      kadaluarsaController.text = widget.dataObat?['kadaluarsa'] ?? '';
    } else {
      status = "Tambah Data Obat";
    }
  }

  Future tambahObat() async {
    return await http.post(
      Uri.parse("http://localhost:8080/mobile2/API_Tugas_Kelompok_2/obat/create.php"),
      body: {
        "id_obat": idObatController.text,
        "nama": namaController.text,
        "stok": stokController.text,
        "harga": hargaController.text,
        "deskripsi": deskripsiController.text,
        "kadaluarsa": kadaluarsaController.text,
      },
    );
  }

  Future updateObat() async {
    return await http.post(
      Uri.parse("http://localhost:8080/mobile2/API_Tugas_Kelompok_2/obat/update.php"),
      body: {
        "id_obat": widget.dataObat?['id_obat'],
        "nama": namaController.text,
        "stok": stokController.text,
        "harga": hargaController.text,
        "deskripsi": deskripsiController.text,
        "kadaluarsa": kadaluarsaController.text,
      },
    );
  }

  bool validasiInput() {
    if ([idObatController, namaController, deskripsiController, stokController, hargaController, kadaluarsaController]
        .any((ctrl) => ctrl.text.isEmpty)) {
      tampilkanPesan("Semua kolom wajib diisi", isError: true);
      return false;
    }
    if (int.tryParse(stokController.text) == null) {
      tampilkanPesan("Stok harus berupa angka", isError: true);
      return false;
    }
    if (int.tryParse(hargaController.text) == null) {
      tampilkanPesan("Harga harus berupa angka", isError: true);
      return false;
    }
    try {
      dateFormat.parse(kadaluarsaController.text);
    } catch (_) {
      tampilkanPesan("Tanggal kadaluarsa tidak valid", isError: true);
      return false;
    }
    return true;
  }

  void tampilkanPesan(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(kadaluarsaController.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      kadaluarsaController.text = dateFormat.format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(status)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(controller: idObatController, decoration: const InputDecoration(labelText: "ID OBAT")),
                  TextFormField(controller: namaController, decoration: const InputDecoration(labelText: "NAMA OBAT")),
                  TextFormField(controller: deskripsiController, decoration: const InputDecoration(labelText: "DESKRIPSI")),
                  TextFormField(controller: stokController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "STOK")),
                  TextFormField(controller: hargaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "HARGA")),
                  TextFormField(
                    controller: kadaluarsaController,
                    readOnly: true,
                    onTap: () => selectDate(context),
                    decoration: const InputDecoration(labelText: "KADALUARSA"),
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (!validasiInput()) return;
                            setState(() => isLoading = true);

                            final response = widget.dataObat == null
                                ? await tambahObat()
                                : await updateObat();

                            setState(() => isLoading = false);

                            if (response.statusCode == 200) {
                              tampilkanPesan(widget.dataObat == null
                                  ? "Data berhasil ditambahkan"
                                  : "Data berhasil diedit");
                              Navigator.pop(context, true);
                            } else {
                              tampilkanPesan("Gagal menyimpan data", isError: true);
                            }
                          },
                          child: Text(widget.dataObat == null ? "Tambah" : "Edit"),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}