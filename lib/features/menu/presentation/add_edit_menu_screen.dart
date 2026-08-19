import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../logic/menu_cubit.dart';
import '../data/menu_repository.dart';
import '../../../main.dart'; // Untuk memanggil getIt

class AddEditMenuScreen extends StatefulWidget {
  final Map<String, dynamic>? menuData;
  const AddEditMenuScreen({super.key, this.menuData});


  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryBrown = const Color(0xFF3C2A21);
  final Color bgColor = const Color(0xFFFAF8F5);

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _volumeController;

  List<Map<String, String>> _ingredients = [];
  bool _isActive = true;

  // State untuk penanganan foto
  File? _selectedImage;
  List<String> _existingImageUrls = [];
  bool _isUploading = false; // Indikator loading saat upload

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuData?['name'] ?? '');
    _priceController = TextEditingController(text: widget.menuData?['price']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.menuData?['description'] ?? '');
    _volumeController = TextEditingController(text: widget.menuData?['volume'] ?? '');
    _isActive = widget.menuData?['is_active'] ?? true;

    // Load gambar lama jika dalam mode edit
    if (widget.menuData != null && widget.menuData!['image_urls'] != null) {
      final List dynamicUrls = widget.menuData!['image_urls'];
      _existingImageUrls = dynamicUrls.map((e) => e.toString()).toList();
    }

    // Load ingredients lama jika dalam mode edit
    if (widget.menuData != null && widget.menuData!['ingredients'] != null) {
      final List dynamicIngredients = widget.menuData!['ingredients'];
      _ingredients = dynamicIngredients.map((e) => {
        'name': e['name'].toString(),
        'grammage': e['grammage'].toString()
      }).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Minimal masukkan 1 ingredient!'))
        );
        return;
      }

      setState(() => _isUploading = true);

      // Default gunakan URL lama jika ada
      List<String> finalImageUrls = List.from(_existingImageUrls);

      try {
        // 1. Jika admin memilih foto baru, upload ke MinIO dulu
        if (_selectedImage != null) {
          final repo = getIt<MenuRepository>();
          final uploadedUrl = await repo.uploadImage(_selectedImage!);
          finalImageUrls = [uploadedUrl]; // Replace dengan URL baru dari MinIO
        }

        // 2. Siapkan Payload (Sesuai dengan ProductRequest DTO)
        final payload = {
          "name": _nameController.text,
          "price": int.parse(_priceController.text),
          "volume": _volumeController.text,
          "description": _descriptionController.text,
          "is_active": _isActive,
          "ingredients": _ingredients,
          "image_urls": finalImageUrls,
        };

        // 3. Panggil Cubit untuk eksekusi Create atau Update
        if (widget.menuData == null) {
          await context.read<MenuCubit>().createMenu(payload);
        } else {
          await context.read<MenuCubit>().updateMenu(widget.menuData!['id'], payload);
        }

        // 4. Tutup halaman jika berhasil
        if (mounted) Navigator.pop(context);

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.menuData != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)
        ),
        title: Text(
            isEdit ? 'Edit Menu Item' : 'Add Menu Item',
            style: const TextStyle(color: Colors.black, fontSize: 18)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Product Photo'),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    // Tampilkan gambar yang dipilih, atau gambar lama dari internet
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : (_existingImageUrls.isNotEmpty
                        ? DecorationImage(image: NetworkImage(_existingImageUrls.first), fit: BoxFit.cover)
                        : null),
                  ),
                  child: _selectedImage == null && _existingImageUrls.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: primaryBrown, size: 32),
                      const SizedBox(height: 8),
                      Text('Upload Item Image', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.w600)),
                      Text('Tap to browse', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Item Name'),
              _buildTextField(_nameController, 'e.g. Single Origin Pour Over'),

              const SizedBox(height: 16),
              _buildLabel('Price (₽)'),
              _buildTextField(_priceController, '₽ 0', isNumber: true),

              const SizedBox(height: 16),
              _buildLabel('Volume'),
              _buildTextField(_volumeController, 'e.g. 250ml or 1 Cup'),

              const SizedBox(height: 16),
              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the flavor notes, origin...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBrown)),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Ingredients (Required)'),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: primaryBrown),
                    onPressed: () {
                      setState(() {
                        _ingredients.add({'name': 'Kopi', 'grammage': '10g'});
                      });
                    },
                  )
                ],
              ),
              ..._ingredients.asMap().entries.map((entry) {
                int idx = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _ingredients[idx]['name'],
                          onChanged: (val) => _ingredients[idx]['name'] = val,
                          decoration: const InputDecoration(labelText: 'Name', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: _ingredients[idx]['grammage'],
                          onChanged: (val) => _ingredients[idx]['grammage'] = val,
                          decoration: const InputDecoration(labelText: 'Grammage', isDense: true),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(idx);
                          });
                        },
                      )
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _saveMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: _isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                      _isUploading ? 'Uploading & Saving...' : (isEdit ? 'Update Item' : 'Save New Item'),
                      style: const TextStyle(color: Colors.white, fontSize: 16)
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Field ini tidak boleh kosong' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryBrown)),
      ),
    );
  }
}