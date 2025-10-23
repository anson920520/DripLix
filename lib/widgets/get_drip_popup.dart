import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopInfo {
  final String onlineShopTitle;
  final String onlineShopItemUrl;
  final String physicalStoreTitle;
  final String physicalStoreAddress;

  const ShopInfo({
    required this.onlineShopTitle,
    required this.onlineShopItemUrl,
    required this.physicalStoreTitle,
    required this.physicalStoreAddress,
  });
}

class GetDripPopup extends StatelessWidget {
  final List<ShopInfo> shops;
  final VoidCallback? onReturn;

  const GetDripPopup({
    super.key,
    required this.shops,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 500,
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
          child: Column(
            children: [
              // Header with "Get Drip" title (white background)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Get Drip',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Scrollable content with shop information
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < shops.length; i++) ...[
                        // Online shop information
                        _buildShopSection(
                          'Online Shop ${i + 1}',
                          [
                            _buildShopText('Shop Title', shops[i].onlineShopTitle),
                            _buildShopUrlWithLogo('Shop URL', shops[i].onlineShopItemUrl),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Physical store information
                        _buildShopSection(
                          'Physical Store ${i + 1}',
                          [
                            _buildShopText('Store Title', shops[i].physicalStoreTitle),
                            _buildShopText('Store Address', shops[i].physicalStoreAddress),
                          ],
                        ),
                        if (i < shops.length - 1) ...[
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: Colors.black12,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              // Return button (fixed at bottom, smaller)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Container(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopSection(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSerif(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...fields,
      ],
    );
  }

  Widget _buildShopText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopUrlWithLogo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
          Row(
            children: [
              Image.asset(
                '/Users/alexhin0719/Downloads/DripLix/assets/images/logos/app_logo_small.png',
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.link,
                      size: 10,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
