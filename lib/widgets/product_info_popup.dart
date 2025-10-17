import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductInfoPopup extends StatelessWidget {
  final String id;
  final String title;
  final String brand;
  final double price;
  final String category;
  final String color;
  final List<String> tags;
  final String shopTitle;
  final VoidCallback? onReturn;
  final VoidCallback? onTryOn;

  const ProductInfoPopup({
    super.key,
    required this.id,
    required this.title,
    required this.brand,
    required this.price,
    required this.category,
    required this.color,
    required this.tags,
    required this.shopTitle,
    this.onReturn,
    this.onTryOn,
  });

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
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              children: [
                // Item Info title (centered)
                Text(
                  'Item Info',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                // Product details (left aligned)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailField('Title', title),
                        const SizedBox(height: 20),
                        _buildDetailField('Category', category),
                        const SizedBox(height: 20),
                        _buildDetailField('Color', color),
                        const SizedBox(height: 20),
                        _buildDetailField('Brand', brand),
                        const SizedBox(height: 20),
                        _buildDetailField('Shop', shopTitle),
                      ],
                    ),
                  ),
                ),
                // Try On and Return buttons in same row (centered, smaller)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Try On button with Free Trial badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 120,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: onTryOn,
                              borderRadius: BorderRadius.circular(8),
                              child: const Center(
                                child: Text(
                                  'Try On',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'Free trial',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Return button
                      Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE6F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: onReturn,
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Text(
                              'Return',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSerif(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
