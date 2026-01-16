import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller
import 'package:nusaniaga/app/modules/home/controllers/home_controller.dart';
import 'package:nusaniaga/app/modules/detail_menu/controllers/detail_menu_controller.dart';

// Import Views Lain
import 'package:nusaniaga/app/modules/Poin/views/poin_view.dart';
import 'package:nusaniaga/app/modules/Profile/views/profile_view.dart';
import 'package:nusaniaga/app/modules/promo/views/promo_view.dart';
import 'package:nusaniaga/app/modules/checkout/views/checkout_view.dart';
import 'package:nusaniaga/app/modules/detail_menu/views/detail_menu_view.dart';

// --- WARNA & HELPER ---
const Color _kPrimaryColor = Color(0xFF2563EB);
const Color _kSecondaryColor = Color(0xFF3B82F6);
const Color _kBackgroundColor = Color(0xFFF8FAFC);
const Color _kAccentColor = Color(0xFFFBBF24);

String formatRupiah(dynamic number) {
  if (number == null) return "Rp 0";
  int value = 0;
  try {
    if (number is num) {
      value = number.toInt();
    } else {
      String clean = number.toString().replaceAll(RegExp(r'[^0-9]'), '');
      value = int.tryParse(clean) ?? 0;
    }
  } catch (e) {
    value = 0;
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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const PromoView(),
      const SizedBox(),
      const PoinView(),
      const ProfileView(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kBackgroundColor,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex == 2 ? 0 : _selectedIndex,
          children: pages,
        ),
        floatingActionButton: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            heroTag: 'home_cart_fab',
            onPressed: () => Get.to(() => const CheckoutView()),
            backgroundColor: _kSecondaryColor,
            elevation: 8,
            shape: const CircleBorder(),
            child: const Icon(
              Ionicons.bag_handle,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          color: Colors.white,
          elevation: 20,
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

  Widget _buildHomeContent() {
    return Obx(() {
      final slides = controller.banners
          .map((b) => {'image': b['image_url'] ?? b['image'] ?? ''})
          .toList();

      final displayProducts = controller.filteredProducts.map((product) {
        double realRating = 0.0;
        if (product['rating'] != null) {
          realRating = double.tryParse(product['rating'].toString()) ?? 0.0;
        }
        double realPrice = 0.0;
        if (product['price'] != null) {
          realPrice = double.tryParse(product['price'].toString()) ?? 0.0;
        }
        String imgUrl = product['image_url'] ?? product['image'] ?? '';

        return {
          'id': product['id'].toString(),
          'name': product['name'] ?? 'Tanpa Nama',
          'type': product['category'] ?? 'Umum',
          'price': realPrice,
          'rating': realRating,
          'image': imgUrl,
          'description': product['description'] ?? '',
          'stock': product['stock'] ?? 0,
          'is_favorite': product['is_favorite'] ?? false,
        };
      }).toList();

      return RefreshIndicator(
        color: Colors.transparent,
        backgroundColor: Colors.transparent,
        strokeWidth: 0,
        displacement: 20,
        onRefresh: () async {
          await controller.refreshHomeData();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModernHeader(
                name: controller.userName.value,
                address: controller.address.value,
                searchQuery: controller.searchQuery.value,
                onSearchChanged: (val) => controller.searchQuery.value = val,
                onClearSearch: () => controller.searchQuery.value = "",
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (slides.isNotEmpty) ...[
                          const Text(
                            "Spesial Hari Ini 🔥",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _CleanPromoSlider(promoSlides: slides),
                          const SizedBox(height: 25),
                        ],
                        const Text(
                          "Pilihan Menu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CleanGridMenu(
                          menu: displayProducts,
                          onItemTap: (item) {
                            Get.to(
                              () => const DetailMenuView(),
                              arguments: item,
                              binding: BindingsBuilder(() {
                                Get.put(DetailMenuController());
                              }),
                            );
                          },
                          onFavoriteTap: (id) {
                            controller.toggleFavorite(id);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (controller.isReloading.value)
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            color: Colors.white.withOpacity(0.6),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: _kPrimaryColor,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Memperbarui Data...",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ModernHeader extends StatelessWidget {
  final String name;
  final String address;
  final Function(String) onSearchChanged;
  final String searchQuery;
  final VoidCallback onClearSearch;

  const _ModernHeader({
    required this.name,
    required this.address,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPrimaryColor, Color(0xFF1D4ED8)],
        ),
        // 👇 PERBAIKAN: Diubah menjadi zero (kotak, tidak melengkung)
        borderRadius: BorderRadius.zero,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Halo, ",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "$name 👋",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Ionicons.location,
                        color: _kAccentColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 200,
                        child: Text(
                          address.isEmpty ? "Mencari lokasi..." : address,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Ionicons.notifications_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: onSearchChanged,
              controller: TextEditingController(text: searchQuery)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: searchQuery.length),
                ),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Mau makan apa hari ini?",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(
                  Ionicons.search,
                  color: _kPrimaryColor,
                  size: 22,
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
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanGridMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menu;
  final Function(Map<String, dynamic>) onItemTap;
  final Function(String) onFavoriteTap;

  const _CleanGridMenu({
    required this.menu,
    required this.onItemTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Ionicons.fast_food_outline,
                size: 60,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                "Menu tidak ditemukan",
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
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
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = menu[index];
        final bool isFav = item['is_favorite'] == true;
        double rating = item['rating'] ?? 0.0;
        String ratingStr = rating <= 0 ? "Baru" : rating.toStringAsFixed(1);

        return GestureDetector(
          onTap: () => onItemTap(item),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.06),
                  blurRadius: 15,
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
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: (item['image'].toString().startsWith('http')
                              ? Image.network(
                                  item['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Image.asset(item['image'], fit: BoxFit.cover)),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: _kAccentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ratingStr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onFavoriteTap(item['id']),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              isFav ? Ionicons.heart : Ionicons.heart_outline,
                              color: isFav ? Colors.red : Colors.grey[400],
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['type'] ?? 'Umum',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 👇 PERBAIKAN: Baris harga sekarang hanya berisi teks harga (kotak icon plus dihapus)
                      Text(
                        formatRupiah(item['price']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: _kPrimaryColor,
                        ),
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
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: promoSlides.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(promoSlides[index]['image']),
                fit: BoxFit.cover,
                onError: (e, s) {},
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? _kPrimaryColor : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _kPrimaryColor : Colors.grey[400],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
