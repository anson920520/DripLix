import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistItemPopup extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String brand;
  final String shop;
  final String dateAdded;
  final VoidCallback onReturn;
  final VoidCallback onTryOn;
  final VoidCallback? onDelete; // null to hide
  final VoidCallback? onMoveToWardrobe; // null to hide

  const WishlistItemPopup({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.brand,
    required this.shop,
    required this.dateAdded,
    required this.onReturn,
    required this.onTryOn,
    this.onDelete,
    this.onMoveToWardrobe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Drip Desire',
                style: GoogleFonts.notoSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title.isEmpty ? 'Untitled' : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                brand.isEmpty ? 'Brand' : brand,
                style: GoogleFonts.notoSerif(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              _readonlyField('Shop', shop.isEmpty ? '—' : shop),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              _readonlyField('Date added', dateAdded.isEmpty ? '—' : dateAdded),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: onReturn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Return'),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: onTryOn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Try On'),
                      ),
                      if (onDelete != null)
                        TextButton(
                          onPressed: onDelete,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: const Text('Delete'),
                        ),
                      if (onMoveToWardrobe != null)
                        OutlinedButton(
                          onPressed: onMoveToWardrobe,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black54),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: const Text('Move to Wardrobe'),
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              GoogleFonts.notoSerif(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.notoSerif(fontSize: 16),
        ),
      ],
    );
  }
}
