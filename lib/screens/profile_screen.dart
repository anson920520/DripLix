import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/logged_in_navigation_bar.dart';
import '../widgets/profile_tabs_panel.dart';
import '../widgets/social_links_panel.dart';
import '../widgets/edit_profile_popup.dart';
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
  String userBio = '{user_bio}{user_bio}{user_bio}{user_bio}{user_bio}';
  int following = 128;
  int followers = 4203;
  int likesAndBookmarks = 12345;
  bool isSelf = true; // toggle to simulate own vs other profile
  final List<Map<String, String>> _socialLinks = [
    {'platform': 'IG', 'username': 'johnwick888'},
    {'platform': 'TikTok', 'username': 'johnwick.official'},
    {'platform': 'X', 'username': 'johnwick888'},
    {'platform': 'YouTube', 'username': 'johnwick.official'},
    {'platform': 'Spotify', 'username': 'johnwick888'},
  ];

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered group: avatar + names/bio + stats
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Container(
                    width: 160,
                    height: 160,
                    color: const Color(0xFFECE6F0),
                    child: const Icon(Icons.person, size: 64, color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 12),
                // Names and bio
                SizedBox(
                  width: 200, // Fixed width to prevent layout shifts
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
                        style: const TextStyle(fontSize: 14, color: Colors.black54, decoration: TextDecoration.underline),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userBio,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Stats in column
                Column(
                  children: [
                    _statBlock(following, 'Following'),
                    const SizedBox(height: 8),
                    _statBlock(followers, 'Followers'),
                    const SizedBox(height: 8),
                    _statBlock(likesAndBookmarks, 'Likes & Bookmarks'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Buttons row below info - moved further left
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Move buttons further left
                _primaryButton(
                  isSelf ? 'Edit Profile' : 'Send friend request',
                  onPressed: _onEditProfile,
                  filled: true,
                ),
                const SizedBox(width: 12),
                _primaryButton('Share Profile', onPressed: () {}, filled: true),
                if (!isSelf) ...[
                  const SizedBox(width: 12),
                  _primaryButton('Follow', onPressed: () {}, filled: true),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tabs panel
          Expanded(
            child: ProfileTabsPanel(
              activeTabIndex: _activeTabIndex,
              onTabChanged: (index) => setState(() => _activeTabIndex = index),
              content: _tabContent(),
            ),
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


  Widget _tabContent() {
    if (_activeTabIndex == 0) {
      return _placeholderGrid('OOTD Post');
    } else if (_activeTabIndex == 1) {
      return _placeholderGrid('Bookmark');
    } else {
      return SocialLinksPanel(socialLinks: _socialLinks);
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
          child: EditProfilePopup(
            initialCustomName: userCustomName,
            initialUserName: userName,
            onSave: (customName, username, gender, socials) {
              setState(() {
                userCustomName = customName;
                userName = username;
                _socialLinks.clear();
                _socialLinks.addAll(socials);
              });
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }
}
