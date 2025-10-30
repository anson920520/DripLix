import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductImagePopup extends StatefulWidget {
  final String title;
  final String brand;
  final String imageUrl;
  final VoidCallback? onFitting;
  final VoidCallback? onGetDrip;

  const ProductImagePopup({
    super.key,
    required this.title,
    required this.brand,
    required this.imageUrl,
    this.onFitting,
    this.onGetDrip,
  });

  @override
  State<ProductImagePopup> createState() => _ProductImagePopupState();
}

class _ProductImagePopupState extends State<ProductImagePopup> {
  int _currentImageIndex = 0;
  
  // Mock multiple images - in real app, this would come from API
  late final List<String> _imageUrls = [
    widget.imageUrl,
    widget.imageUrl, // Using same image for demo
    widget.imageUrl,
  ];

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + _imageUrls.length) % _imageUrls.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 450,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _imageUrls[_currentImageIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.black45, size: 64),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Navigation arrows
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _ImageNavigationArrow(
                            direction: AxisDirection.left,
                            onPressed: _previousImage,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _ImageNavigationArrow(
                            direction: AxisDirection.right,
                            onPressed: _nextImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Image dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _imageUrls.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      _buildImageDot(i == _currentImageIndex),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Product title and brand (left aligned)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.notoSerif(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.brand,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Fitting and Get Drip buttons (right aligned, smaller)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: InkWell(
                          onTap: widget.onFitting,
                          borderRadius: BorderRadius.circular(6),
                          child: const Center(
                            child: Text(
                              'Fitting',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: InkWell(
                          onTap: widget.onGetDrip,
                          borderRadius: BorderRadius.circular(6),
                          child: const Center(
                            child: Text(
                              'Get Drip',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ImageNavigationArrow extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onPressed;

  const _ImageNavigationArrow({
    required this.direction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLeft = direction == AxisDirection.left;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Image.asset(
              isLeft 
                ? 'assets/images/homepage/button/chevron_backward.png'
                : 'assets/images/homepage/button/chevron_forward.png',
              width: 16,
              height: 16,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  isLeft ? Icons.chevron_left : Icons.chevron_right,
                  size: 16,
                  color: Colors.black87,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
