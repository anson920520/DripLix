import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/logged_in_navigation_bar.dart';
import '../widgets/profile_tabs_panel.dart';
import '../widgets/social_links_panel.dart';
import '../widgets/confirm_dialog.dart';
import '../services/auth_state.dart';

class ViewProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userCustomName;
  final String userName;
  final String userBio;
  final int following;
  final int followers;
  final int likesAndBookmarks;
  final List<Map<String, String>> socialLinks;

  const ViewProfileScreen({
    super.key,
    required this.userId,
    required this.userCustomName,
    required this.userName,
    required this.userBio,
    required this.following,
    required this.followers,
    required this.likesAndBookmarks,
    required this.socialLinks,
  });

  @override
  ConsumerState<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends ConsumerState<ViewProfileScreen> {
  int _activeTabIndex = 0; // 0=OOTD, 1=Bookmarks, 2=Social Media
  
  // Friend/Follow states
  FriendState _friendState = FriendState.notFriends;
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Column(
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
        if (isLoggedIn)
          const Positioned(
              left: 0, right: 0, bottom: 0, child: LoggedInBottomNavBar(activeIndex: 0)),
      ]),
    );
  }

  Widget _buildProfilePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                      widget.userCustomName,
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${widget.userName}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.userBio,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Stats in column
              Column(
                children: [
                  _statBlock(widget.following, 'Following'),
                  const SizedBox(height: 8),
                  _statBlock(widget.followers, 'Followers'),
                  const SizedBox(height: 8),
                  _statBlock(widget.likesAndBookmarks, 'Likes & Bookmarks'),
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
                  _getFriendButtonText(),
                  onPressed: _onFriendButtonPressed,
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
                      _primaryButton(
                        _isFollowing ? 'Following' : 'Follow',
                        onPressed: _onFollowButtonPressed,
                        filled: false,
                      ),
                      _primaryButton('Share Profile', onPressed: () {}, filled: false),
                    ],
                  ),
                ),
              ),
            ],
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
      return SocialLinksPanel(socialLinks: widget.socialLinks);
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

  String _getFriendButtonText() {
    switch (_friendState) {
      case FriendState.notFriends:
        return 'Add Friend';
      case FriendState.requestSent:
        return 'Sent Friend Request';
      case FriendState.friends:
        return 'Friend';
    }
  }

  void _onFriendButtonPressed() {
    switch (_friendState) {
      case FriendState.notFriends:
        setState(() => _friendState = FriendState.requestSent);
        break;
      case FriendState.requestSent:
        // Could show a dialog to cancel request
        break;
      case FriendState.friends:
        _showUnfriendDialog();
        break;
    }
  }

  void _onFollowButtonPressed() {
    if (_isFollowing) {
      _showUnfollowDialog();
    } else {
      setState(() => _isFollowing = true);
    }
  }

  void _showUnfriendDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: 'Confirm to unfriend?',
        content: 'Please note that once you confirm this action, you will lose your connection with your friend.',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onConfirm: () {
          setState(() => _friendState = FriendState.notFriends);
          Navigator.of(ctx).pop();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showUnfollowDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: 'Confirm to unfollow?',
        content: 'Please note that once you confirm this action, you may miss out.',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onConfirm: () {
          setState(() => _isFollowing = false);
          Navigator.of(ctx).pop();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

enum FriendState {
  notFriends,
  requestSent,
  friends,
}
