import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_state.dart';
import '../widgets/logged_in_navigation_bar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/edit_item_popup.dart';
import '../widgets/item_preview_popup.dart';

class _WardrobeCard extends StatefulWidget {
  final _WardrobeItem item;
  final double height;
  final VoidCallback onEdit;

  const _WardrobeCard({
    required this.item,
    required this.height,
    required this.onEdit,
  });

  @override
  State<_WardrobeCard> createState() => _WardrobeCardState();
}

class _WardrobeCardState extends State<_WardrobeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final double rowHeight = widget.height;
    final Widget card = AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      scale: _hovered ? 1.03 : 1.0,
      child: InkWell(
        onTap: widget.onEdit,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: rowHeight - 70,
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
                          color: Colors.black.withValues(alpha: 0.18),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Divider line between image and text
              Container(height: 1, color: Colors.black12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSerif(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  // Top tabs on the left panel
  static const List<String> _modes = <String>[
    'My Wardrobe',
    "Friends' Wardrobe",
    'My Wishlist',
    "Friends' Wishlist",
  ];
  int _activeModeIndex = 0;

  // Filters
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedColor;
  String? _selectedBrand;
  String? _selectedTag;
  bool _isCategoryOpen = false;
  bool _isColorOpen = false;
  bool _isBrandOpen = false;
  bool _isTagOpen = false;
  bool _isLoading = false;
  final Map<String, ScrollController> _categoryScrollControllers =
      <String, ScrollController>{};

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

  // Mock wardrobe items grouped by category
  late final Map<String, List<_WardrobeItem>> _itemsByCategory =
      _generateMock();

  @override
  void dispose() {
    _searchController.dispose();
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
              ? const LoggedInNavigationBar(initialActiveIndex: 1)
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
                      Expanded(child: _buildRightWardrobe()),
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
              color: Colors.black.withValues(alpha: 0.08),
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
              // Mode selector (vertical text list with selected highlight)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<Widget>.generate(_modes.length, (int i) {
                  final bool active = _activeModeIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => _onModeSelected(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 325,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFE3DCDC)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _modes[i],
                          style: GoogleFonts.notoSerif(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 60,
                  height: 2,
                  color: const Color(0xFFD9D9D9),
                ),
              ),
              const SizedBox(height: 12),
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
    return Container(
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
                // close arrow when a value is selected
                setState(() {
                  onChanged(v);
                  // handled per label below
                  if (label == 'Category') _isCategoryOpen = false;
                  if (label == 'Color') _isColorOpen = false;
                  if (label == 'Brand') _isBrandOpen = false;
                  if (label == 'Tag') _isTagOpen = false;
                });
                _triggerLoading();
              },
              onTap: () {
                // open state toggles icon to down arrow after click
                setState(() {
                  if (label == 'Category') _isCategoryOpen = true;
                  if (label == 'Color') _isColorOpen = true;
                  if (label == 'Brand') _isBrandOpen = true;
                  if (label == 'Tag') _isTagOpen = true;
                });
              },
              icon: Icon(
                (label == 'Category' && _isCategoryOpen) ||
                        (label == 'Color' && _isColorOpen) ||
                        (label == 'Brand' && _isBrandOpen) ||
                        (label == 'Tag' && _isTagOpen)
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

  Widget _buildRightWardrobe() {
    final List<String> categories = _itemsByCategory.keys.toList();
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
              // Header with current wardrobe type (independent 1206x49 bar)
              SizedBox(
                height: 49,
                child: Center(
                  child: Container(
                    width: 1206,
                    height: 49,
                    color: const Color(0xFFE3DCDC),
                    alignment: Alignment.center,
                    child: Text(
                      _modes[_activeModeIndex],
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Hanger logo line
              SizedBox(
                height: 56,
                child: Center(
                  child: Container(
                    width: 640,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black26, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _openAddNewItemPopup,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/wardrobe/iconstack.io - (Hanger).png',
                          width: 28,
                          height: 28,
                          errorBuilder: (c, e, s) =>
                              const SizedBox(width: 28, height: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Body scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        for (final String category in categories) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3DCDC),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                category,
                                style: GoogleFonts.notoSerif(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _SmallSideArrow(
                                direction: AxisDirection.left,
                                onPressed: () =>
                                    _scrollCategory(category, -300),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 240,
                                  child: _buildCategoryRow(
                                    _itemsByCategory[category] ??
                                        <_WardrobeItem>[],
                                    category,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _SmallSideArrow(
                                direction: AxisDirection.right,
                                onPressed: () => _scrollCategory(category, 300),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildCategoryRow(List<_WardrobeItem> items, String category) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double rowHeight = 220;
        final ScrollController controller = _controllerFor(category);
        return Stack(
          children: [
            ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final _WardrobeItem item = items[index];
                final double aspect = (item.width > 0 && item.height > 0)
                    ? item.width / item.height
                    : 1.0;
                final double cardWidth = (rowHeight - 20) * aspect;
                return SizedBox(
                  width: cardWidth.clamp(160, 360),
                  child: _WardrobeCard(
                    item: item,
                    height: rowHeight,
                    onEdit: () {
                      _openEditPopup(
                        imageUrl: item.imageUrl,
                        title: item.title,
                        brand: item.brand,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  ScrollController _controllerFor(String category) {
    return _categoryScrollControllers.putIfAbsent(
        category, () => ScrollController());
  }

  void _scrollCategory(String category, double delta) {
    final ScrollController controller = _controllerFor(category);
    final double target = (controller.offset + delta)
        .clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _onModeSelected(int index) {
    setState(() {
      _activeModeIndex = index;
    });
    _triggerLoading();
  }

  Future<void> _triggerLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _openEditPopup({
    required String imageUrl,
    required String title,
    required String brand,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preview window
                ItemPreviewPopup(
                  width: 600,
                  height: 938,
                  imageUrl: imageUrl,
                  title: title,
                  brand: brand,
                  onClose: () => Navigator.of(ctx).pop(),
                ),
                const SizedBox(width: 16),
                // Editor window (form-only)
                EditItemPopup(
                  width: 600,
                  height: 938,
                  initialTitle: title,
                  initialBrand: brand,
                  onSave: (edited) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item saved')),
                    );
                  },
                  onDelete: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item deleted')),
                    );
                  },
                  onReturn: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddNewItemPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String currentTitle = '';
        String currentBrand = '';
        String currentImageUrl = '';
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ItemPreviewPopup(
                      width: 600,
                      height: 938,
                      imageUrl: currentImageUrl,
                      title: currentTitle,
                      brand: currentBrand,
                      onClose: () => Navigator.of(ctx).pop(),
                      onUploadRequested: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Upload image not implemented')),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    EditItemPopup(
                      width: 600,
                      height: 938,
                      initialTitle: currentTitle,
                      initialBrand: currentBrand,
                      onTitleChanged: (v) => setStateSB(() => currentTitle = v),
                      onBrandChanged: (v) => setStateSB(() => currentBrand = v),
                      onSave: (edited) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item created')),
                        );
                      },
                      onDelete: () {
                        Navigator.of(ctx).pop();
                      },
                      onReturn: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedColor = null;
      _selectedBrand = null;
      _selectedTag = null;
    });
    _triggerLoading();
  }

  Map<String, List<_WardrobeItem>> _generateMock() {
    final List<_WardrobeItem> base = List<_WardrobeItem>.generate(18, (int i) {
      final bool even = i % 2 == 0;
      final String img = even
          ? 'assets/images/homepage/carousel_template_image_1.png'
          : 'assets/images/homepage/carousel_template_image_2.png';
      final int w = even ? 1200 : 900;
      final int h = even ? 900 : 1200;
      return _WardrobeItem(
        title: 'Item ${i + 1}',
        brand: 'Brand ${String.fromCharCode(65 + (i % 5))}',
        category: _categories[i % _categories.length],
        imageUrl: img,
        width: w,
        height: h,
      );
    });
    final Map<String, List<_WardrobeItem>> grouped =
        <String, List<_WardrobeItem>>{};
    for (final _WardrobeItem item in base) {
      grouped.putIfAbsent(item.category, () => <_WardrobeItem>[]).add(item);
    }
    return grouped;
  }
}

class _WardrobeItem {
  final String title;
  final String brand;
  final String category;
  final String imageUrl;
  final int width;
  final int height;

  const _WardrobeItem({
    required this.title,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.width,
    required this.height,
  });
}

class _CarouselArrow extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onPressed;

  const _CarouselArrow({
    required this.direction,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLeft = direction == AxisDirection.left;
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: IconButton(
        onPressed: onPressed,
        iconSize: 18,
        splashRadius: 18,
        icon: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.black87,
        ),
        tooltip: isLeft ? 'Previous' : 'Next',
      ),
    );
  }
}

class _SmallSideArrow extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onPressed;

  const _SmallSideArrow({
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
        child: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          size: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
