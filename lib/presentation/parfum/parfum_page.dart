import 'dart:io'; // Untuk kelas File
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parfumku/data/model/parfum_model.dart'; // Pastikan path ini benar
import 'package:parfumku/presentation/parfum/bloc/parfum_bloc.dart';
import 'package:parfumku/presentation/parfum/bloc/parfum_event.dart';
import 'package:parfumku/presentation/parfum/bloc/parfum_state.dart';

class ParfumPage extends StatefulWidget {
  const ParfumPage({super.key});

  @override
  State<ParfumPage> createState() => _ParfumPageState();
}

class _ParfumPageState extends State<ParfumPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  File? _imageFile; // Variabel untuk menyimpan file gambar yang dipilih
  final ImagePicker _picker = ImagePicker();

  Parfum? _editingParfum;
  // Gunakan GlobalKey untuk validasi form di dalam AlertDialog
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Memuat daftar parfum saat halaman diinisialisasi
    context.read<ParfumBloc>().add(LoadParfums());
  }

  // Fungsi untuk mengambil gambar dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70, // Kompresi gambar untuk mengurangi ukuran file
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set file gambar yang dipilih
      });
    }
  }

  // Menampilkan sheet aksi untuk memilih sumber gambar (kamera/galeri)
  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Menampilkan dialog form untuk menambah atau mengedit parfum
  void _showParfumForm({Parfum? parfum}) {
    _editingParfum = parfum; // Set parfum yang sedang diedit
    if (parfum != null) {
      // Jika mode edit, isi controller dengan data parfum yang ada
      _nameController.text = parfum.name;
      _descriptionController.text = parfum.description;
      _priceController.text = parfum.price.toStringAsFixed(0);
      _stockController.text = parfum.stock.toString();
      _categoryController.text = parfum.category;
      // Penting: Reset _imageFile saat membuka form edit,
      // karena kita akan menampilkan gambar yang sudah ada dari URL.
      // Pengguna bisa memilih gambar baru jika diperlukan.
      setState(() {
        _imageFile = null;
      });
    } else {
      // Jika mode tambah, kosongkan semua controller
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
      _categoryController.clear();
      setState(() {
        _imageFile = null; // Pastikan _imageFile null untuk form baru
      });
    }

    // Menampilkan dialog form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parfum == null ? 'Tambah Parfum' : 'Edit Parfum'),
        content: StatefulBuilder( // Gunakan StatefulBuilder untuk memperbarui UI dalam dialog
          builder: (BuildContext context, StateSetter setStateInner) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey, // Kunci form untuk validasi
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Widget untuk menampilkan gambar yang dipilih atau gambar dari URL lama
                    GestureDetector(
                      onTap: () async {
                        await _showImageSourceActionSheet(context);
                        setStateInner(() {}); // Update state di dalam dialog agar gambar muncul
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imageFile != null // Jika ada gambar baru yang dipilih
                            ? Image.file(
                                _imageFile!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            // Jika tidak ada gambar baru, tapi ada parfum lama dengan imageUrl
                            : (parfum != null && parfum.imageUrl.isNotEmpty // Cek juga jika stringnya tidak kosong
                                ? Image.network(
                                      parfum.imageUrl, // imageUrl di model sudah non-nullable, tidak perlu '!'
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 100),
                                    )
                                // Jika tidak ada gambar baru dan tidak ada imageUrl lama (atau kosong)
                                : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image, size: 50, color: Colors.grey),
                                        Text('Pilih Gambar', style: TextStyle(color: Colors.grey)),
                                      ],
                                    )),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _showImageSourceActionSheet(context);
                        setStateInner(() {});
                      },
                      child: const Text('Pilih Gambar'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Validasi form sebelum submit
                final newParfum = Parfum(
                  id: _editingParfum?.id, // ID hanya ada jika mengedit
                  name: _nameController.text,
                  description: _descriptionController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  stock: int.tryParse(_stockController.text) ?? 0,
                  category: _categoryController.text,
                  // imageUrl di sini hanya untuk representasi di objek Dart lokal.
                  // _imageFile (File) yang akan dikirim untuk upload.
                  // Kita bisa menggunakan imageUrl dari _editingParfum jika ada,
                  // atau string kosong jika ini parfum baru atau imageUrl lama tidak ada.
                  imageUrl: _editingParfum?.imageUrl ?? '',
                );

                if (_editingParfum == null) {
                  // Mode tambah parfum
                  context.read<ParfumBloc>().add(
                        AddParfum(newParfum, imageFile: _imageFile),
                      );
                } else {
                  // Mode edit parfum
                  context.read<ParfumBloc>().add(
                        UpdateParfum(newParfum, imageFile: _imageFile),
                      );
                }
                Navigator.pop(context); // Tutup dialog setelah submit
              }
            },
            child: Text(parfum == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  // Konfirmasi penghapusan parfum
  void _confirmDeleteParfum(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Parfum'),
        content: const Text('Apakah Anda yakin ingin menghapus parfum ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ParfumBloc>().add(DeleteParfum(id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Parfum')),
      body: BlocConsumer<ParfumBloc, ParfumState>(
        listener: (context, state) {
          if (state is ParfumOperationSuccess) {
            // Tampilkan pesan sukses dan muat ulang data
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            // Pastikan Anda memuat ulang parfum setelah operasi berhasil
            context.read<ParfumBloc>().add(LoadParfums()); // <<<--- PENTING: Muat ulang data setelah sukses
          } else if (state is ParfumError) {
            // Tampilkan pesan error
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ParfumLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ParfumLoaded) {
            if (state.parfums.isEmpty) {
              return const Center(child: Text('Tidak ada data parfum.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.parfums.length,
              itemBuilder: (context, index) {
                final parfum = state.parfums[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: parfum.imageUrl.isNotEmpty // imageUrl non-nullable, cek apakah kosong
                        ? Image.network(
                              parfum.imageUrl, // imageUrl di model sudah non-nullable, tidak perlu '!'
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50),
                            )
                        : const Icon(Icons.image, size: 50), // Akan ditampilkan jika imageUrl kosong
                    title: Text(parfum.name),
                    subtitle: Text(
                      'Rp ${parfum.price.toStringAsFixed(0)} | Stok: ${parfum.stock} | Kategori: ${parfum.category}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showParfumForm(parfum: parfum),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteParfum(parfum.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ParfumError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol tambah untuk menambahkan parfum.'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showParfumForm(), // Memanggil form untuk menambah parfum baru
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}