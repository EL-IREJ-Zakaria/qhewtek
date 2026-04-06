import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/menu_item.dart';

class MenuItemFormData {
  const MenuItemFormData({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.available,
    this.imagePath,
    this.imageValue,
  });

  final String name;
  final String description;
  final double price;
  final String category;
  final bool available;
  final String? imagePath;
  final String? imageValue;
}

class MenuItemFormSheet extends StatefulWidget {
  const MenuItemFormSheet({super.key, this.initialItem});

  final MenuItem? initialItem;

  @override
  State<MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late String _category;
  late bool _available;
  XFile? _selectedImage;
  Uint8List? _selectedPreview;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController.text = item?.name ?? '';
    _descriptionController.text = item?.description ?? '';
    _priceController.text = item != null ? item.price.toStringAsFixed(2) : '';
    _imageController.text = item?.image ?? '';
    _category = item?.category.isNotEmpty == true ? item!.category : 'coffee';
    _available = item?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 84,
      maxWidth: 1600,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    setState(() {
      _selectedImage = image;
      _selectedPreview = bytes;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      MenuItemFormData(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _category,
        available: _available,
        imagePath: _selectedImage?.path,
        imageValue: _imageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit menu item' : 'Add menu item',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Keep the waiter app and customer QR menu in sync with the same catalog.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (_selectedPreview != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.memory(
                    _selectedPreview!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.initialItem?.imageUrl case final existingImage?)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    existingImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload image'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  prefixIcon: Icon(Icons.local_cafe_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a menu item name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.subject_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid price.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
                  DropdownMenuItem(value: 'drinks', child: Text('Drinks')),
                  DropdownMenuItem(value: 'desserts', child: Text('Desserts')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available for ordering'),
                value: _available,
                onChanged: (value) => setState(() => _available = value),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    isEditing ? Icons.save_outlined : Icons.add_rounded,
                  ),
                  label: Text(isEditing ? 'Save changes' : 'Create item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
