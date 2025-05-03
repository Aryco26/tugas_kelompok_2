import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './crud_obat.dart';

class Obat extends StatefulWidget {
  const Obat({Key? key}) : super(key: key);

  @override
  ObatState createState() => ObatState();
}

class ObatState extends State<Obat> {
  List _obatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshDataObat();
  }

  Future<void> refreshDataObat() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          "http://localhost:8080/mobile2/API_Tugas_Kelompok_2/obat/list.php"));

      if (response.statusCode == 200) {
        setState(() {
          _obatList = json.decode(response.body);
        });
      } else {
        showError("Gagal memuat data. Kode: ${response.statusCode}");
      }
    } catch (e) {
      showError("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> hapusDataObat(String idObat) async {
    final response = await http.post(
      Uri.parse("http://localhost:8080/mobile2/API_Tugas_Kelompok_2/obat/delete.php"),
      body: {'id_obat': idObat},
    );

    if (response.statusCode == 200) {
      refreshDataObat();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil dihapus")),
      );
    } else {
      showError("Gagal menghapus data.");
    }
  }

  void confirmHapusDataObat(String idObat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text("Apakah anda yakin ingin menghapus data ini?"),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text("Batal"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Hapus"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              hapusDataObat(idObat);
            },
          ),
        ],
      ),
    );
  }

  String formatTanggal(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Obat")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _obatList.isEmpty
              ? const Center(child: Text("Data kosong"))
              : ListView.builder(
                  itemCount: _obatList.length,
                  itemBuilder: (context, index) {
                    final obat = _obatList[index];
                    final kadaluarsa = formatTanggal(obat['kadaluarsa']);
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text('${index + 1}. ${obat['nama']}'),
                        subtitle: Text('Stok: ${obat['stok']} | Kadaluarsa: $kadaluarsa'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CrudObat(dataObat: obat),
                                  ),
                                );
                                if (result == true) refreshDataObat();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                confirmHapusDataObat(obat['id_obat']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrudObat(dataObat: null)),
          );
          if (result == true) refreshDataObat();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}