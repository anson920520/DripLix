import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePopup extends StatefulWidget {
  final String initialCustomName;
  final String initialUserName;
  final void Function(String customName, String userName, String gender, List<Map<String, String>> socials) onSave;

  const EditProfilePopup({
    super.key,
    required this.initialCustomName,
    required this.initialUserName,
    required this.onSave,
  });

  @override
  State<EditProfilePopup> createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  late TextEditingController _customNameController;
  late TextEditingController _userNameController;
  String _gender = 'Prefer not to say';
  final List<Map<String, String>> _socials = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _customNameController = TextEditingController(text: widget.initialCustomName);
    _userNameController = TextEditingController(text: widget.initialUserName);
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 640,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Center(
              child: Text(
                'Edit Profile',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Profile picture section with clickable text
            _buildProfilePictureSection(),
            const SizedBox(height: 16),
            // Name field
            _labeledField('Name', _customNameController),
            const SizedBox(height: 12),
            // User field
            _labeledField('User', _userNameController),
            const SizedBox(height: 12),
            // Gender
            _genderField(),
            const SizedBox(height: 12),
            // Social media list
            _socialsField(),
            const SizedBox(height: 16),
            // Save / Cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _dialogButton('Save Change', filled: true, onPressed: () {
                  widget.onSave(
                    _customNameController.text,
                    _userNameController.text,
                    _gender,
                    _socials,
                  );
                }),
                const SizedBox(width: 10),
                _dialogButton('Cancel', filled: false, onPressed: () {
                  Navigator.of(context).pop();
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        // Profile picture placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(48),
          child: Container(
            width: 96,
            height: 96,
            color: const Color(0xFFECE6F0),
            child: const Icon(Icons.person, size: 48, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 8),
        // Clickable text to show profile picture editor
        InkWell(
          onTap: _showProfilePictureEditor,
          child: const Text(
            'Edit Profile Picture',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showProfilePictureEditor() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: _ProfilePictureEditor(
            selectedImage: _selectedImage,
            onImageSelected: (image) {
              setState(() {
                _selectedImage = image;
              });
            },
          ),
        ),
      ),
    );
  }


  void _showCropDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crop Image'),
        content: const Text('Image cropping functionality would be implemented here with a library like image_cropper.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECE6F0),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => controller.clear(),
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/signup/cancel.png',
                  width: 18,
                  height: 18,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.clear, size: 16, color: Colors.black54);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECE6F0),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              items: const [
                'Male', 'Female', 'Non-binary', 'Prefer not to say'
              ].map((g) => DropdownMenuItem<String>(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _gender = v ?? _gender),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Social Media:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        for (int i = 0; i < _socials.length; i++) ...[
          _socialRow(i),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _socials.add({'platform': 'IG', 'username': ''});
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black54),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('+ Add Social', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        )
      ],
    );
  }

  Widget _socialRow(int index) {
    final TextEditingController userController = TextEditingController(text: _socials[index]['username'] ?? '');
    String platform = _socials[index]['platform'] ?? 'IG';

    return Row(
      children: [
        // Platform selector
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFECE6F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: platform,
              items: const ['IG', 'Facebook', 'X', 'TikTok', 'Discord', 'YouTube', 'Spotify', 'Threads', '微博', '小红书', '虎扑', 'Other']
                  .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _socials[index]['platform'] = v ?? platform;
                });
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Username field
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFECE6F0),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'username',
                    ),
                    onChanged: (v) => _socials[index]['username'] = v,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => userController.clear(),
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/signin/cancel.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.clear, size: 16, color: Colors.black54);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dialogButton(String text, {required bool filled, required VoidCallback onPressed}) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? Colors.black : Colors.transparent,
          side: BorderSide(color: filled ? Colors.black : Colors.black54, width: 1),
          foregroundColor: filled ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ProfilePictureEditor extends StatefulWidget {
  final File? selectedImage;
  final Function(File?) onImageSelected;

  const _ProfilePictureEditor({
    required this.selectedImage,
    required this.onImageSelected,
  });

  @override
  State<_ProfilePictureEditor> createState() => _ProfilePictureEditorState();
}

class _ProfilePictureEditorState extends State<_ProfilePictureEditor> {
  File? _currentImage;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.selectedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Edit Profile Picture',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Big profile picture with overlay buttons
            _buildBigProfilePicture(),
            const SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _dialogButton('Cancel', filled: false, onPressed: () {
                  Navigator.of(context).pop();
                }),
                const SizedBox(width: 12),
                _dialogButton('Save', filled: true, onPressed: () {
                  widget.onImageSelected(_currentImage);
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigProfilePicture() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Big profile picture
        ClipRRect(
          borderRadius: BorderRadius.circular(80),
          child: Container(
            width: 160,
            height: 160,
            color: const Color(0xFFECE6F0),
            child: _currentImage != null
                ? Image.file(_currentImage!, fit: BoxFit.cover)
                : const Icon(Icons.person, size: 80, color: Colors.black54),
          ),
        ),
        // Overlay buttons - one left, one right
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              onPressed: _pickImage,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: _pickImage,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _currentImage = File(image.path);
      });
      
      // Here you would typically show a crop dialog
      // For now, we'll just use the selected image
      _showCropDialog();
    }
  }

  void _showCropDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crop Image'),
        content: const Text('Image cropping functionality would be implemented here with a library like image_cropper.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _dialogButton(String text, {required bool filled, required VoidCallback onPressed}) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? Colors.black : Colors.transparent,
          side: BorderSide(color: filled ? Colors.black : Colors.black54, width: 1),
          foregroundColor: filled ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
