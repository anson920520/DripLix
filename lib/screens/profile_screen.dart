import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/logged_in_navigation_bar.dart';
import '../services/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data
  String userCustomName = '{user_custom_name}';
  String userName = 'user_name';
  String userBio = '{user_bio}';
  int following = 128;
  int followers = 4203;
  int likesAndBookmarks = 12345;
  bool isSelf = true; // toggle to simulate own vs other profile

  int _activeTabIndex = 0; // 0=OOTD, 1=Bookmarks, 2=Social Media

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthScope.of(context).isLoggedIn;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          isLoggedIn
              ? const LoggedInNavigationBar(initialActiveIndex: 0)
              : const SizedBox.shrink(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  child: _buildProfilePanel(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + names/bio + stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 120,
                  height: 120,
                  color: const Color(0xFFECE6F0),
                  child: const Icon(Icons.person, size: 64, color: Colors.black54),
                ),
              ),
              const SizedBox(width: 16),
              // Names and bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userCustomName,
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$userName',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userBio,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Stats
              Row(
                children: [
                  _statBlock(following, 'Followings'),
                  const SizedBox(width: 24),
                  _statBlock(followers, 'Follows'),
                  const SizedBox(width: 24),
                  _statBlock(likesAndBookmarks, 'Likes and Bookmarks'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons row below info
          Row(
            children: [
              // Left: under avatar
              SizedBox(
                width: 120,
                child: _primaryButton(
                  isSelf ? 'Edit Profile' : 'Send friend request',
                  onPressed: _onEditProfile,
                  filled: false,
                ),
              ),
              const SizedBox(width: 12),
              // Right under bio
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (!isSelf)
                        _primaryButton('Follow', onPressed: () {}, filled: true),
                      _primaryButton('Share Profile', onPressed: () {}, filled: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tabs
          _tabs(),
          const SizedBox(height: 12),
          // Content area switches by tab
          SizedBox(
            height: 520,
            child: _tabContent(),
          ),
        ],
      ),
    );
  }

  Widget _statBlock(int value, String label) {
    return Column(
      children: [
        Text(
          _formatNumber(value),
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  Widget _primaryButton(String text, {required VoidCallback onPressed, bool filled = true}) {
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

  Widget _tabs() {
    final List<String> tabs = ['OOTD', 'Bookmarks', 'Social Media'];
    return Row(
      children: List<Widget>.generate(tabs.length, (int i) {
        final bool active = _activeTabIndex == i;
        return Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: InkWell(
            onTap: () => setState(() => _activeTabIndex = i),
            borderRadius: BorderRadius.circular(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[i],
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 3,
                  width: active ? 50 : 0,
                  decoration: const BoxDecoration(color: Colors.black),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _tabContent() {
    if (_activeTabIndex == 0) {
      return _placeholderGrid('OOTD Post');
    } else if (_activeTabIndex == 1) {
      return _placeholderGrid('Bookmark');
    } else {
      return _placeholderGrid('Social');
    }
  }

  Widget _placeholderGrid(String label) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFECE6F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Center(
            child: Text('$label ${index + 1}', style: const TextStyle(color: Colors.black54)),
          ),
        );
      },
    );
  }

  void _onEditProfile() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: _EditProfilePopup(
            initialCustomName: userCustomName,
            initialUserName: userName,
            onSave: (customName, username, gender, socials) {
              setState(() {
                userCustomName = customName;
                userName = username;
              });
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }
}

class _EditProfilePopup extends StatefulWidget {
  final String initialCustomName;
  final String initialUserName;
  final void Function(String customName, String userName, String gender, List<Map<String, String>> socials) onSave;

  const _EditProfilePopup({
    required this.initialCustomName,
    required this.initialUserName,
    required this.onSave,
  });

  @override
  State<_EditProfilePopup> createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<_EditProfilePopup> {
  late TextEditingController _customNameController;
  late TextEditingController _userNameController;
  String _gender = 'Prefer not to say';
  final List<Map<String, String>> _socials = [];

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
            color: Colors.black.withOpacity(0.18),
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
            const Text('Edit Profile Picture', style: TextStyle(fontSize: 12, color: Colors.black87)),
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

  Widget _labeledField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label + ':', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
              items: const ['IG', 'Facebook', 'X', 'TikTok']
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
