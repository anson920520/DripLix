import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewItemPopup extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String brand;
  final VoidCallback onReturn;
  final VoidCallback onTryOn;

  const ViewItemPopup({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.brand,
    required this.onReturn,
    required this.onTryOn,
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
                'Item Details',
                style: GoogleFonts.notoSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              // Prominent title and brand
              Text(
                title.isEmpty ? 'Untitled' : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                brand.isEmpty ? 'Brand' : brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSerif(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              _readonlyField('Category', '—'),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              _readonlyField('Color', '—'),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              _readonlyField('Tag', '—'),
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
                  ElevatedButton(
                    onPressed: onTryOn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Try On'),
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
          style: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.notoSerif(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
