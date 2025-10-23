import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemPreviewPopup extends StatelessWidget {
  final double width; // e.g., 600
  final double height; // e.g., 938
  final String imageUrl;
  final String title;
  final String brand;
  final VoidCallback onClose;
  final VoidCallback? onUploadRequested;
  final bool showWishlistActions;
  final VoidCallback? onFitting;
  final VoidCallback? onGetDrip;

  const ItemPreviewPopup({
    super.key,
    required this.width,
    required this.height,
    required this.imageUrl,
    required this.title,
    required this.brand,
    required this.onClose,
    this.onUploadRequested,
    this.showWishlistActions = false,
    this.onFitting,
    this.onGetDrip,
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
        child: Column(
          children: [
            Expanded(
              child: imageUrl.isEmpty
                  ? InkWell(
                      onTap: onUploadRequested,
                      child: Container(
                        constraints: const BoxConstraints.expand(),
                        color: const Color(0xFFF3EDF7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload,
                                size: 48, color: Colors.black54),
                            const SizedBox(height: 8),
                            Text('Upload Image',
                                style: GoogleFonts.notoSerif()),
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.black45),
                              ),
                            );
                          },
                        ),
                        if (showWishlistActions)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Row(
                              children: [
                                _actionChip('Fitting', onFitting),
                                const SizedBox(width: 8),
                                _actionChip('Get Drip', onGetDrip),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black12),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'Untitled' : title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSerif(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          brand.isEmpty ? 'Brand' : brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSerif(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(String label, VoidCallback? onPressed) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSerif(fontSize: 12, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
