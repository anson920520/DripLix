import 'package:flutter/material.dart';

class SocialLinksPanel extends StatelessWidget {
  final List<Map<String, String>> socialLinks;

  const SocialLinksPanel({
    super.key,
    required this.socialLinks,
  });

  @override
  Widget build(BuildContext context) {
    if (socialLinks.isEmpty) {
      return const Center(
        child: Text(
          'No social media links added yet',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Two-column layout for social media links
          ...List.generate((socialLinks.length / 2).ceil(), (rowIndex) {
            final leftIndex = rowIndex * 2;
            final rightIndex = leftIndex + 1;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Left column - left aligned
                  Expanded(
                    child: _buildSocialLink(socialLinks[leftIndex]),
                  ),
                  const SizedBox(width: 16),
                  // Right column - left aligned
                  Expanded(
                    child: rightIndex < socialLinks.length 
                        ? _buildSocialLink(socialLinks[rightIndex])
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSocialLink(Map<String, String> social) {
    final platform = social['platform'] ?? '';
    final username = social['username'] ?? '';
    
    return Row(
      children: [
        _getSocialIcon(platform),
        const SizedBox(width: 8),
        Text(
          username,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _getSocialIcon(String platform) {
    IconData iconData;
    
    switch (platform.toLowerCase()) {
      case 'ig':
      case 'instagram':
        iconData = Icons.camera_alt;
        break;
      case 'facebook':
      case 'fb':
        iconData = Icons.facebook;
        break;
      case 'x':
      case 'twitter':
        iconData = Icons.close; // X symbol
        break;
      case 'tiktok':
        iconData = Icons.music_note;
        break;
      case 'youtube':
        iconData = Icons.play_arrow;
        break;
      case 'spotify':
        iconData = Icons.music_note;
        break;
      case 'threads':
        iconData = Icons.link;
        break;
      case 'discord':
        iconData = Icons.discord;
        break;
      case '微博':
      case 'weibo':
        iconData = Icons.public;
        break;
      case '小红书':
      case 'xiaohongshu':
        iconData = Icons.photo_camera;
        break;
      case '虎扑':
      case 'hupu':
        iconData = Icons.sports_basketball;
        break;
      default:
        iconData = Icons.link;
    }
    
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        iconData,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
