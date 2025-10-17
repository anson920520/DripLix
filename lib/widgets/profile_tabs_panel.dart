import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTabsPanel extends StatelessWidget {
  final int activeTabIndex;
  final Function(int) onTabChanged;
  final Widget content;

  const ProfileTabsPanel({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs header - separate panel
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildTabs(),
          ),
        ),
        const SizedBox(height: 8),
        // Content area - separate panel
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabs() {
    final List<String> tabs = ['OOTD', 'Bookmarks', 'Social Media'];
    return List<Widget>.generate(tabs.length, (int i) {
      final bool active = activeTabIndex == i;
      return Expanded(
        child: InkWell(
          onTap: () => onTabChanged(i),
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
    });
  }
}
