import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller & Views
import 'package:nusaniaga/app/modules/home/controllers/home_controller.dart';
// Pastikan import di bawah ini sesuai struktur folder Anda
import 'package:nusaniaga/app/modules/Poin/views/poin_view.dart';
import 'package:nusaniaga/app/modules/Profile/views/profile_view.dart';
import 'package:nusaniaga/app/modules/promo/views/promo_view.dart';
import 'package:nusaniaga/app/modules/checkout/views/checkout_view.dart';
import 'package:nusaniaga/app/modules/detail_menu/views/detail_menu_view.dart';

// Konstanta Warna
const Color _kBackgroundColor = Color(0xFFFFFFFF);
const Color _kSearchBarColor = Color(0xFFF5F5F5);
const Color _kAccentColor = Color(0xFF6E4E3A);

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

  // State Lokal untuk Filter Tab
  String _selectedCategory = "All";
  int _selectedIndex = 0;

  // Logic Filter Menu: Menggabungkan hasil search API + filter kategori Lokal
  List<Map<String, dynamic>> get _currentMenu {
    List<dynamic> sourceData = controller.filteredProducts;

    // Filter Logic Lokal
    if (_selectedCategory != "All") {
      sourceData = sourceData.where((p) {
        String cat = (p['category'] ?? '').toString().toLowerCase();
        return cat == _selectedCategory.toLowerCase();
      }).toList();
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

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildHomeContent() {
    return Obx(() {
      // Loading indikator
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

              // === Judul Filter ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Kategori Menu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),

              // === Widget Filter Kategori (Dinamis dari DB) ===
              // Menggunakan Obx agar list update otomatis saat data dari controller masuk
              Obx(
                () => _CategoryFilterList(
                  categories: controller.categoryList
                      .toList(), // Ambil dari Controller
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              ),

              // === List Menu ===
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

class _CategoryFilterList extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const _CategoryFilterList({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Jika data kategori belum masuk (masih kosong/loading)
    if (categories.isEmpty) {
      return const SizedBox(height: 40);
    }

    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _kAccentColor : _kSearchBarColor,
                borderRadius: BorderRadius.circular(30),
                border: isSelected
                    ? Border.all(color: _kAccentColor)
                    : Border.all(color: Colors.transparent),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    child: img.startsWith('http')
                        ? Image.network(
                            img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                        : Image.asset(
                            img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => controller.toggleFavorite(item['id']),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item['type'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatRupiah(item['price']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _kAccentColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kSearchBarColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['rating'].toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
            "Menu tidak ditemukan untuk kategori ini",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menu.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
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
      elevation: 0,
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
