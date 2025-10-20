import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_state.dart';
import '../widgets/logged_in_navigation_bar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/product_info_popup.dart';
import '../widgets/product_image_popup.dart';
import '../widgets/get_drip_popup.dart';

class _MarketplaceCard extends StatefulWidget {
  final _MarketplaceItem item;
  final double height;
  final VoidCallback onTap;

  const _MarketplaceCard({
    required this.item,
    required this.height,
    required this.onTap,
  });

  @override
  State<_MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<_MarketplaceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final double rowHeight = widget.height;
    final Widget card = AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      scale: _hovered ? 1.03 : 1.0,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: rowHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.black45),
                        ),
                      );
                    },
                  ),
                  if (_hovered)
                    Container(
                      color: Colors.black.withOpacity(0.18),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.visibility, color: Colors.white, size: 32),
                      ),
                    ),
                  // Orange Free Trial text box (on top of image)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Free trial',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: card,
    );
  }
}

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  // Filters
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedColor;
  String? _selectedBrand;
  String? _selectedTag;
  String? _selectedPlatform;
  bool _isCategoryOpen = false;
  bool _isColorOpen = false;
  bool _isBrandOpen = false;
  bool _isTagOpen = false;
  bool _isPlatformOpen = false;
  bool _tryOnMode = true; // Default to "Free Trial"
  bool _isLoading = false;

  // Keyword bar
  final ScrollController _keywordScrollController = ScrollController();
  late final List<String> _keywords;

  // Mock data for dropdowns
  static const List<String> _categories = <String>[
    'Tops',
    'Bottoms',
    'Outerwear',
    'Footwear',
    'Accessories'
  ];
  static const List<String> _colors = <String>[
    'Black',
    'White',
    'Gray',
    'Blue',
    'Red',
    'Green'
  ];
  static const List<String> _brands = <String>[
    'Brand A',
    'Brand B',
    'Brand C',
    'Brand D'
  ];
  static const List<String> _tags = <String>[
    'Casual',
    'Formal',
    'Street',
    'Sport',
    'Vintage'
  ];
  static const List<String> _platforms = <String>[
    'Shopify',
    'Amazon',
    'eBay',
    'Etsy'
  ];

  // Mock marketplace items
  late final List<_MarketplaceItem> _marketplaceItems = _generateMockItems();

  @override
  void initState() {
    super.initState();
    _initializeKeywords();
  }

  void _initializeKeywords() {
    // Extract unique categories and tags from products
    final Set<String> categorySet = _categories.toSet();
    final Set<String> tagSet = _tags.toSet();
    
    _keywords = [
      '{keywords}',
      ...categorySet,
      ...tagSet,
    ].toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _keywordScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = ref.watch(authProvider);
    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          isLoggedIn
              ? LoggedInNavigationBar(initialActiveIndex: 3)
              : CustomNavigationBar(
                  isListUnfolded: false,
                  onListToggle: () {},
                ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1370),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeftPanel(),
                      const SizedBox(width: 16),
                      Expanded(child: _buildRightPanel()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return SizedBox(
      width: 345,
      height: 952,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCF1F1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters header
              Text(
                'Filters',
                style: GoogleFonts.notoSerif(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // Search field
              _searchField(),
              const SizedBox(height: 12),
              // Dropdowns
              _dropdownField(
                label: 'Category',
                value: _selectedCategory,
                options: _categories,
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                label: 'Color',
                value: _selectedColor,
                options: _colors,
                onChanged: (v) => setState(() => _selectedColor = v),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                label: 'Brand',
                value: _selectedBrand,
                options: _brands,
                onChanged: (v) => setState(() => _selectedBrand = v),
              ),
              const SizedBox(height: 12),
              _dropdownField(
                label: 'Tag',
                value: _selectedTag,
                options: _tags,
                onChanged: (v) => setState(() => _selectedTag = v),
              ),
              const SizedBox(height: 12),
              // Try-On Mode switch
              _tryOnModeSwitch(),
              const SizedBox(height: 12),
              _dropdownField(
                label: 'e-Commerce Platform',
                value: _selectedPlatform,
                options: _platforms,
                onChanged: (v) => setState(() => _selectedPlatform = v),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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

  Widget _searchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search',
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECE6F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Input',
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () {
                  _triggerLoading();
                },
                icon: const Icon(Icons.search, size: 18, color: Colors.black54),
                splashRadius: 18,
                tooltip: 'Search',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECE6F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Text('All'),
              items: options
                  .map((String v) => DropdownMenuItem<String>(
                        value: v,
                        child: Text(v),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  onChanged(v);
                  if (label == 'Category') _isCategoryOpen = false;
                  if (label == 'Color') _isColorOpen = false;
                  if (label == 'Brand') _isBrandOpen = false;
                  if (label == 'Tag') _isTagOpen = false;
                  if (label == 'e-Commerce Platform') _isPlatformOpen = false;
                });
                _triggerLoading();
              },
              onTap: () {
                setState(() {
                  if (label == 'Category') _isCategoryOpen = true;
                  if (label == 'Color') _isColorOpen = true;
                  if (label == 'Brand') _isBrandOpen = true;
                  if (label == 'Tag') _isTagOpen = true;
                  if (label == 'e-Commerce Platform') _isPlatformOpen = true;
                });
              },
              icon: Icon(
                (label == 'Category' && _isCategoryOpen) ||
                        (label == 'Color' && _isColorOpen) ||
                        (label == 'Brand' && _isBrandOpen) ||
                        (label == 'Tag' && _isTagOpen) ||
                        (label == 'e-Commerce Platform' && _isPlatformOpen)
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tryOnModeSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try-On Mode',
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _tryOnMode = !_tryOnMode;
                });
              },
              child: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: _tryOnMode ? Colors.black : Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: _tryOnMode ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _tryOnMode ? 'Free Trial' : 'Disable',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.black12, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Marketplace title
              SizedBox(
                height: 49,
                child: Center(
                  child: Container(
                    width: 1206,
                    height: 49,
                    color: const Color(0xFFE3DCDC),
                    alignment: Alignment.center,
                    child: Text(
                      'Marketplace',
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Keyword bar
              _buildKeywordBar(),
              // Product grid
              Expanded(
                child: _buildProductGrid(),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKeywordBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _KeywordArrow(
            direction: AxisDirection.left,
            onPressed: () => _scrollKeywords(-200),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              controller: _keywordScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _keywords.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6F0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    _keywords[index],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          _KeywordArrow(
            direction: AxisDirection.right,
            onPressed: () => _scrollKeywords(200),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _marketplaceItems.length,
        itemBuilder: (context, index) {
          final item = _marketplaceItems[index];
          return _MarketplaceCard(
            item: item,
            height: 280,
            onTap: () => _openProductDetailPopup(item),
          );
        },
      ),
    );
  }

  void _scrollKeywords(double delta) {
    final double target = (_keywordScrollController.offset + delta)
        .clamp(0.0, _keywordScrollController.position.maxScrollExtent);
    _keywordScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _triggerLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedColor = null;
      _selectedBrand = null;
      _selectedTag = null;
      _selectedPlatform = null;
      _tryOnMode = true;
    });
    _triggerLoading();
  }

  List<_MarketplaceItem> _generateMockItems() {
    return List<_MarketplaceItem>.generate(20, (int i) {
      return _MarketplaceItem(
        id: 'prod-${i + 1}',
        title: 'Product ${i + 1}',
        brand: 'Brand ${String.fromCharCode(65 + (i % 5))}',
        price: 29.99 + (i * 10.0),
        imageUrl: 'assets/images/homepage/carousel_template_image_1.png',
        category: _categories[i % _categories.length],
        color: _colors[i % _colors.length],
        tags: [_tags[i % _tags.length]],
        shop: _ShopInfo(
          onlineShopTitle: 'Online Store ${i + 1}',
          onlineShopItemUrl: 'https://example.com/product${i + 1}',
          physicalStoreTitle: 'Store ${i + 1}',
          physicalStoreAddress: '${100 + i} Main St, City ${i + 1}',
        ),
      );
    });
  }

  void _openProductDetailPopup(_MarketplaceItem item) {
    // Show both popups side by side
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Stack(
          children: [
            // Product Info Popup (left)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 475,
              top: MediaQuery.of(context).size.height / 2 - 300,
              child: ProductInfoPopup(
                id: item.id,
                title: item.title,
                brand: item.brand,
                price: item.price,
                category: item.category,
                color: item.color,
                tags: item.tags,
                shopTitle: item.shop.onlineShopTitle,
                onReturn: () => Navigator.of(ctx).pop(),
                onTryOn: () {
                  // TODO: Implement try on functionality
                  Navigator.of(ctx).pop();
                },
              ),
            ),
            // Product Image Popup (right)
            Positioned(
              right: MediaQuery.of(context).size.width / 2 - 475,
              top: MediaQuery.of(context).size.height / 2 - 300,
              child: ProductImagePopup(
                title: item.title,
                brand: item.brand,
                imageUrl: item.imageUrl,
                onFitting: () {
                  // TODO: Implement fitting functionality
                  Navigator.of(ctx).pop();
                },
                onGetDrip: () {
                  Navigator.of(ctx).pop();
                  _openGetDripPopup(item);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openGetDripPopup(_MarketplaceItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return GetDripPopup(
          shops: [ShopInfo(
            onlineShopTitle: item.shop.onlineShopTitle,
            onlineShopItemUrl: item.shop.onlineShopItemUrl,
            physicalStoreTitle: item.shop.physicalStoreTitle,
            physicalStoreAddress: item.shop.physicalStoreAddress,
          )],
          onReturn: () => Navigator.of(ctx).pop(),
        );
      },
    );
  }
}

class _MarketplaceItem {
  final String id;
  final String title;
  final String brand;
  final double price;
  final String imageUrl;
  final String category;
  final String color;
  final List<String> tags;
  final _ShopInfo shop;

  const _MarketplaceItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.color,
    required this.tags,
    required this.shop,
  });
}

class _ShopInfo {
  final String onlineShopTitle;
  final String onlineShopItemUrl;
  final String physicalStoreTitle;
  final String physicalStoreAddress;

  const _ShopInfo({
    required this.onlineShopTitle,
    required this.onlineShopItemUrl,
    required this.physicalStoreTitle,
    required this.physicalStoreAddress,
  });
}

class _KeywordArrow extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onPressed;

  const _KeywordArrow({
    required this.direction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLeft = direction == AxisDirection.left;
    return SizedBox(
      width: 28,
      height: 28,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(28, 28),
          side: const BorderSide(color: Colors.black26, width: 1),
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
        ),
        child: Image.asset(
          isLeft 
            ? '/Users/alexhin0719/Downloads/DripLix/assets/images/homepage/button/chevron_backward.png'
            : '/Users/alexhin0719/Downloads/DripLix/assets/images/homepage/button/chevron_forward.png',
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
    );
  }
}
