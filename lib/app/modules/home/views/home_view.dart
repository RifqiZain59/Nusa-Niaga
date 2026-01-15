import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller & Views
import 'package:nusaniaga/app/modules/home/controllers/home_controller.dart';
import 'package:nusaniaga/app/modules/Poin/views/poin_view.dart';
import 'package:nusaniaga/app/modules/Profile/views/profile_view.dart';
import 'package:nusaniaga/app/modules/promo/views/promo_view.dart';
import 'package:nusaniaga/app/modules/checkout/views/checkout_view.dart';
import 'package:nusaniaga/app/modules/detail_menu/views/detail_menu_view.dart';

// --- PALET WARNA BIRU MODERN ---
const Color _kPrimaryColor = Color(0xFF0D47A1); // Biru Tua (Primary)
const Color _kSecondaryColor = Color(0xFF42A5F5); // Biru Terang (Secondary)
const Color _kBackgroundColor = Color(
  0xFFF0F4F8,
); // Abu-abu kebiruan (Background)
const Color _kAccentColor = Color(0xFFFFA000); // Amber (untuk kontras/poin)

// --- HELPER ---
String formatRupiah(dynamic number) {
  if (number == null) return "Rp 0";
  int value = 0;
  if (number is String) {
    String clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    value = int.tryParse(clean) ?? 0;
  } else if (number is num) {
    value = number.toInt();
  }
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
  String _selectedCategory = "All";
  int _selectedIndex = 0;

  List<Map<String, dynamic>> get _currentMenu {
    List<dynamic> source = controller.filteredProducts;
    if (_selectedCategory != "All") {
      source = source.where((p) {
        String cat = (p['category'] ?? '').toString();
        return cat.toLowerCase() == _selectedCategory.toLowerCase();
      }).toList();
    }
    return source.map((product) {
      return {
        'id': product['id'].toString(),
        'name': product['name'] ?? 'Tanpa Nama',
        'type': product['category'] ?? 'Umum',
        'price': product['price'] ?? 0,
        'rating': double.tryParse(product['rating'].toString()) ?? 4.5,
        'image': product['image_url'] ?? '',
        'description': product['description'] ?? '',
        'is_favorite': product['is_favorite'] ?? false,
      };
    }).toList();
  }

  // initState dihapus/dikosongkan karena kita pindah ke AnnotatedRegion di build
  @override
  void initState() {
    super.initState();
  }

  Widget _buildHomeContent() {
    return Obx(() {
      final slides = controller.banners
          .map((b) => {'image': b['image_url'] ?? ''})
          .toList();

      return RefreshIndicator(
        color: _kPrimaryColor,
        onRefresh: () async {
          await controller.fetchHomeData();
          await controller.determinePosition();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Kotak & Search
              _SquareHeader(
                address: controller.address.value,
                onSearchChanged: (val) => controller.searchQuery.value = val,
                searchQuery: controller.searchQuery.value,
                onClearSearch: () => controller.searchQuery.value = "",
              ),

              // 2. Body Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo Slider
                    if (slides.isNotEmpty) ...[
                      const Text(
                        "Promo Spesial ⚡",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CleanPromoSlider(promoSlides: slides),
                      const SizedBox(height: 25),
                    ],

                    // Header Kategori
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Kategori",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _kPrimaryColor,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // List Kategori (Chips)
                    _CleanCategoryList(
                      categories: controller.categoryList.toList(),
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (cat) =>
                          setState(() => _selectedCategory = cat),
                    ),

                    const SizedBox(height: 24),

                    // Grid Menu
                    _CleanGridMenu(
                      menu: _currentMenu,
                      onItemTap: (item) =>
                          Get.to(() => const DetailMenuView(), arguments: item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Navigasi Halaman
    final List<Widget> pages = [
      _buildHomeContent(),
      const PromoView(),
      const SizedBox(),
      const PoinView(),
      const ProfileView(),
    ];

    // --- ANNOTATED REGION (Warna Status Bar) ---
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Bagian ATAS (Status Bar)
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Icon Putih
        statusBarBrightness: Brightness.dark, // iOS: Icon Putih
        // Bagian BAWAH (Navigation Bar HP)
        systemNavigationBarColor: Colors.white, // Background Putih
        systemNavigationBarIconBrightness: Brightness.dark, // Icon Hitam
      ),
      child: Scaffold(
        backgroundColor: _kBackgroundColor,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex == 2 ? 0 : _selectedIndex,
          children: pages,
        ),

        // FAB
        floatingActionButton: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () => Get.to(() => const CheckoutView()),
            backgroundColor:
                _kSecondaryColor, // Menggunakan Biru Terang agar menonjol
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(
              Ionicons.bag_handle,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Bottom Navbar
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 15,
          height: 70,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Ionicons.home_outline,
                activeIcon: Ionicons.home,
                label: "Home",
                isSelected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavBarItem(
                icon: Ionicons.pricetags_outline,
                activeIcon: Ionicons.pricetags,
                label: "Promo",
                isSelected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              const SizedBox(width: 48),
              _NavBarItem(
                icon: Ionicons.wallet_outline,
                activeIcon: Ionicons.wallet,
                label: "Poin",
                isSelected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              _NavBarItem(
                icon: Ionicons.person_outline,
                activeIcon: Ionicons.person,
                label: "Profil",
                isSelected: _selectedIndex == 4,
                onTap: () => setState(() => _selectedIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= KOMPONEN =================

class _SquareHeader extends StatelessWidget {
  final String address;
  final Function(String) onSearchChanged;
  final String searchQuery;
  final VoidCallback onClearSearch;

  const _SquareHeader({
    required this.address,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      // Gradient Header Biru
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimaryColor, Color(0xFF1565C0)],
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + 15,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lokasi Kamu",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Ionicons.location,
                          color: _kAccentColor, // Aksen Kuning/Amber
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address.isEmpty ? "Menemukan lokasi..." : address,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Ionicons.notifications,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Cari produk...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(
                  Ionicons.search_outline,
                  color: _kPrimaryColor,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: onClearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanCategoryList extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const _CleanCategoryList({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox(height: 38);
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _kPrimaryColor : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CleanGridMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menu;
  final Function(Map<String, dynamic>) onItemTap;

  const _CleanGridMenu({required this.menu, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Ionicons.cube_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                "Produk belum tersedia",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: menu.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = menu[index];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: (item['image'].toString().startsWith('http')
                              ? Image.network(item['image'], fit: BoxFit.cover)
                              : Image.asset(item['image'], fit: BoxFit.cover)),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  item['rating'].toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['type'],
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatRupiah(item['price']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _kPrimaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _kPrimaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: _kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CleanPromoSlider extends StatelessWidget {
  final List<Map<String, dynamic>> promoSlides;
  const _CleanPromoSlider({required this.promoSlides});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: promoSlides.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
              image: DecorationImage(
                image: NetworkImage(promoSlides[index]['image']),
                fit: BoxFit.cover,
                onError: (e, s) {},
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? _kPrimaryColor : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _kPrimaryColor : Colors.grey[400],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
