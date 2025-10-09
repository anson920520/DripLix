import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditItemData {
  final String title;
  final String category;
  final String color;
  final String brand;
  final String tag;
  final String price;
  final bool friendVisible;

  const EditItemData({
    required this.title,
    required this.category,
    required this.color,
    required this.brand,
    required this.tag,
    required this.price,
    required this.friendVisible,
  });
}

class EditItemPopup extends StatefulWidget {
  final double width; // expected 600
  final double height; // expected 938
  final String initialTitle;
  final String initialBrand;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onBrandChanged;
  final void Function(EditItemData edited) onSave;
  final VoidCallback onDelete;
  final VoidCallback onReturn;

  const EditItemPopup({
    super.key,
    required this.width,
    required this.height,
    required this.initialTitle,
    required this.initialBrand,
    this.onTitleChanged,
    this.onBrandChanged,
    required this.onSave,
    required this.onDelete,
    required this.onReturn,
  });

  @override
  State<EditItemPopup> createState() => _EditItemPopupState();
}

class _EditItemPopupState extends State<EditItemPopup> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _category;
  String? _color;
  String? _tag;
  bool _friendVisible = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _brandController.text = widget.initialBrand;
    _priceController.text = '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Item',
                style: GoogleFonts.notoSerif(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Title', _titleController,
                  onChanged: (v) => widget.onTitleChanged?.call(v)),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Category',
                value: _category,
                items: const <String>[
                  'Top',
                  'Bottom',
                  'Outerwear',
                  'Footwear',
                  'Accessory'
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Color',
                value: _color,
                items: const <String>[
                  'Black',
                  'White',
                  'Gray',
                  'Blue',
                  'Red',
                  'Green',
                  'Beige'
                ],
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: 12),
              _buildTextField('Brand', _brandController,
                  onChanged: (v) => widget.onBrandChanged?.call(v)),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Tag',
                value: _tag,
                items: const <String>[
                  'Casual',
                  'Street',
                  'Formal',
                  'Sport',
                  'Vintage'
                ],
                onChanged: (v) => setState(() => _tag = v),
              ),
              const SizedBox(height: 12),
              _buildTextField('Price', _priceController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Friend Visibility',
                      style: GoogleFonts.notoSerif(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: _friendVisible,
                    onChanged: (v) => setState(() => _friendVisible = v),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: widget.onReturn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Return'),
                  ),
                  TextButton(
                    onPressed: widget.onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final EditItemData data = EditItemData(
                        title: _titleController.text,
                        category: _category ?? '',
                        color: _color ?? '',
                        brand: _brandController.text,
                        tag: _tag ?? '',
                        price: _priceController.text,
                        friendVisible: _friendVisible,
                      );
                      widget.onSave(data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E0E9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Input',
            ),
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: const Color(0xFF333333),
            ),
            onChanged: (v) {
              setState(() {});
              if (onChanged != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E0E9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: GoogleFonts.notoSerif(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              hint: Text('Select', style: GoogleFonts.notoSerif(fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }
}
