import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller & Views (Pastikan path ini sesuai dengan struktur folder Anda)
import 'package:nusaniaga/app/modules/home/controllers/home_controller.dart';
import 'package:nusaniaga/app/modules/Poin/views/poin_view.dart';
import 'package:nusaniaga/app/modules/Profile/views/profile_view.dart';
import 'package:nusaniaga/app/modules/promo/views/promo_view.dart';
import 'package:nusaniaga/app/modules/checkout/views/checkout_view.dart';
import 'package:nusaniaga/app/modules/detail_menu/views/detail_menu_view.dart';

// Konstanta Warna
const Color _kBackgroundColor = Color(0xFFFFFFFF);
const Color _kSearchBarColor = Color(0xFFF5F5F5);
const Color _kAccentColor = Color(0xFF6E4E3A);

enum MenuCategory { nearest, favorite }

// Fungsi Global untuk Format Rupiah
String formatRupiah(dynamic number) {
  if (number == null) return "Rp 0";
  int value = 0;
  if (number is String)
    value = int.tryParse(number) ?? 0;
  else if (number is double)
    value = number.toInt();
  else
    value = number;

  String str = value.toString();
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String result = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  return "Rp $result";
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.put(HomeController());
  MenuCategory _selectedCategory = MenuCategory.nearest;
  int _selectedIndex = 0;

  // Logic Filter Menu
  List<Map<String, dynamic>> get _currentMenu {
    List<dynamic> sourceData = controller.filteredProducts;

    if (_selectedCategory == MenuCategory.favorite) {
      sourceData = sourceData.where((p) => p['is_favorite'] == true).toList();
    }

    return sourceData.map((product) {
      return {
        'id': product['id'],
        'name': product['name'] ?? 'Tanpa Nama',
        'type': product['category'] ?? 'Umum',
        'price': double.tryParse(product['price'].toString()) ?? 0.0,
        'rating':
            double.tryParse(product['rating']?.toString() ?? '4.5') ?? 4.5,
        'image': product['image_url'] ?? '',
        'description': product['description'] ?? '',
        'is_favorite': product['is_favorite'] ?? false,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _setSystemUI();
  }

  // Fungsi untuk mengatur warna status bar dan navigasi bar sistem HP
  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        // Membuat Navigasi Bar HP (bawah) jadi putih
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildHomeContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _kAccentColor),
        );
      }

      final List<Map<String, dynamic>> displaySlides = controller.banners
          .map((b) => {'image': b['image_url'] ?? ''})
          .toList();

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchHomeData();
          await controller.determinePosition();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderAndSearch(address: controller.address.value),
              const SizedBox(height: 5),
              _PromoCard(promoSlides: displaySlides),
              const SizedBox(height: 25),
              _TwoColumnCategoryTabs(
                selectedCategory: _selectedCategory,
                onCategoryTapped: (cat) =>
                    setState(() => _selectedCategory = cat),
              ),
              _HomeListGrid(
                menu: _currentMenu,
                onItemTap: (item) =>
                    Get.to(() => const DetailMenuView(), arguments: item),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Memastikan UI sistem tetap putih saat build ulang
    _setSystemUI();

    final List<Widget> pages = [
      _buildHomeContent(),
      const PromoView(),
      const PoinView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      // Membungkus NavBar dengan Container untuk memberikan Shadow pemisah
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: _CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

// ================= KOMPONEN WIDGET =================

class _HeaderAndSearch extends StatelessWidget {
  final String address;
  const _HeaderAndSearch({required this.address});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    Text(
                      address,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Ionicons.bag_outline),
                onPressed: () => Get.to(() => const CheckoutView()),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: "Search coffee...",
              prefixIcon: const Icon(
                Ionicons.search_outline,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: _kSearchBarColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => controller.searchQuery.value = "",
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const _HomeCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final String img = item['image'] ?? '';
    final bool isFav = item['is_favorite'] ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: img.startsWith('http')
                        ? Image.network(
                            img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                        : Image.asset(
                            img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => controller.toggleFavorite(item['id']),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item['type'],
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatRupiah(item['price']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeListGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menu;
  final Function(Map<String, dynamic>) onItemTap;
  const _HomeListGrid({required this.menu, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text(
            "Menu tidak ditemukan",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: menu.length,
      itemBuilder: (ctx, i) =>
          _HomeCard(item: menu[i], onTap: () => onItemTap(menu[i])),
    );
  }
}

class _PromoCard extends StatefulWidget {
  final List<Map<String, dynamic>> promoSlides;
  const _PromoCard({required this.promoSlides});
  @override
  State<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<_PromoCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.promoSlides.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (t) {
        if (_pageController.hasClients) {
          int next = (_currentPage + 1) % widget.promoSlides.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promoSlides.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AspectRatio(
        aspectRatio: 2.3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (v) => setState(() => _currentPage = v),
                itemCount: widget.promoSlides.length,
                itemBuilder: (context, index) => Image.network(
                  widget.promoSlides[index]['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.promoSlides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: _currentPage == index ? 18 : 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
}

class _TwoColumnCategoryTabs extends StatelessWidget {
  final MenuCategory selectedCategory;
  final Function(MenuCategory) onCategoryTapped;
  const _TwoColumnCategoryTabs({
    required this.selectedCategory,
    required this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: _kSearchBarColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            _buildTab("Terdekat", MenuCategory.nearest),
            _buildTab("Favorit", MenuCategory.favorite),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, MenuCategory cat) {
    bool isSel = selectedCategory == cat;
    return Expanded(
      child: GestureDetector(
        onTap: () => onCategoryTapped(cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSel
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? _kAccentColor : Colors.grey,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const _CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _kAccentColor,
      unselectedItemColor: Colors.black.withOpacity(0.3),
      showSelectedLabels: true,
      backgroundColor: Colors.white,
      elevation:
          0, // Elevation 0 karena bayangan diatur oleh Container pembungkus
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          activeIcon: Icon(Ionicons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.pricetags_outline),
          activeIcon: Icon(Ionicons.pricetags),
          label: 'Promo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.wallet_outline),
          activeIcon: Icon(Ionicons.wallet),
          label: 'Poin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.person_outline),
          activeIcon: Icon(Ionicons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
