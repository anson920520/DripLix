import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final bool isListUnfolded;
  final VoidCallback onListToggle;
  final VoidCallback? onSignUp;
  final VoidCallback? onSignIn;

  const CustomNavigationBar({
    super.key,
    required this.isListUnfolded,
    required this.onListToggle,
    this.onSignUp,
    this.onSignIn,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1920,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Logo on the left
            Image.asset(
              'assets/images/navigation/Driplix Logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'DripLix',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              },
            ),
            const Spacer(),
            // Navigation buttons on the right
            Row(
              children: [
                _buildNavButton('', 'assets/images/navigation/Explore_tab.png'),
                const SizedBox(width: 8),
                _buildNavButton('', 'assets/images/navigation/Sign_in_tab.png',
                    onTap: widget.onSignIn),
                const SizedBox(width: 8),
                _buildNavButton('', 'assets/images/navigation/Sign_up_tab.png',
                    onTap: widget.onSignUp),
                const SizedBox(width: 8),
                _buildNavButton(
                  '',
                  widget.isListUnfolded
                      ? 'assets/images/navigation/unfolded_list_icon.png'
                      : 'assets/images/navigation/folded_list_icon.png',
                  onTap: widget.onListToggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, String imagePath, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        width: 100.0,
        height: 70.0,
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100.0,
              height: 70.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: const Icon(
                Icons.circle,
                size: 40.0,
                color: Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }
}
