import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import 'dart:async' untuk menggunakan Timer
import 'dart:async';
import 'package:ionicons/ionicons.dart';

import 'package:nusaniaga/app/modules/Poin/views/poin_view.dart';
import 'package:nusaniaga/app/modules/Profile/views/profile_view.dart';
import 'package:nusaniaga/app/modules/promo/views/promo_view.dart';
// IMPOR CheckoutView
import 'package:nusaniaga/app/modules/checkout/views/checkout_view.dart';

// LANGKAH 1: Impor halaman DetailMenuView (Ini adalah impor yang BENAR)
import 'package:nusaniaga/app/modules/detail_menu/views/detail_menu_view.dart'; // <-- DIPERTAHANKAN

// Definisi warna (Dibiarkan sama)
const Color _kBackgroundColor = Color(0xFFFFFFFF); // Putih
const Color _kSearchBarColor = Color(0xFFF5F5F5); // Abu-abu sangat terang
const Color _kAccentColor = Color(0xFF1976D2); // Biru Gelap
const Color _kSelectedCategoryColor = Color(0xFF1976D2);
const Color _kCategoryUnselectedBg =
    _kBackgroundColor; // Menggunakan warna latar belakang utama (Putih)
const Color _kCategoryBorderColor = Color(
  0xFFE0E0E0,
); // Abu-abu muda untuk batas

// Enum untuk status kategori yang dipilih
enum MenuCategory { nearest, favorite }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  MenuCategory _selectedCategory = MenuCategory.nearest;
  int _selectedIndex = 0; // Index halaman yang sedang aktif

  // ... (Data menuItems dan menuItemsFavorit tetap sama)
  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Caffe Mocha',
      'type': 'Deep Foam',
      'price': 4.53,
      'rating': 4.8,
      'image': 'assets/mocha.jpg',
      'color': const Color(0xFF003366),
    },
    {
      'name': 'Flat White',
      'type': 'Espresso',
      'price': 3.53,
      'rating': 4.5,
      'image': 'assets/flat_white.jpg',
      'color': const Color(0xFFC7A785),
    },
    {
      'name': 'Cappuccino',
      'type': 'Milk Foam',
      'price': 4.00,
      'rating': 4.9,
      'image': 'assets/cappuccino.jpg',
      'color': const Color(0xFF6B4226),
    },
    {
      'name': 'Espresso',
      'type': 'Single Shot',
      'price': 2.50,
      'rating': 4.2,
      'image': 'assets/espresso.jpg',
      'color': const Color(0xFF4A302A),
    },
  ];

  final List<Map<String, dynamic>> menuItemsFavorit = [
    {
      'name': 'Americano',
      'type': 'Black Coffee',
      'price': 3.00,
      'rating': 5.0,
      'image': 'assets/americano.jpg',
      'color': const Color(0xFF8B4513),
    },
    {
      'name': 'Cappuccino',
      'type': 'Milk Foam',
      'price': 4.00,
      'rating': 4.9,
      'image': 'assets/cappuccino.jpg',
      'color': const Color(0xFF6B4226),
    },
  ];

  List<Map<String, dynamic>> get _currentMenu {
    return _selectedCategory == MenuCategory.favorite
        ? menuItemsFavorit
        : menuItems;
  }

  void _updateCategory(MenuCategory newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }

  // FUNGSI NAVIGASI Checkout
  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutView()),
    );
  }

  // LANGKAH 2: Definisikan fungsi navigasi ke DetailMenuView
  void _navigateToDetail(Map<String, dynamic> item) {
    // Navigasi menggunakan DetailMenuView yang diimpor
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailMenuView(item: item)),
    );
  }

  // Widget pembangun untuk konten Home (Index 0)
  Widget _buildHomeContent() {
    // Daftar gambar promo
    final List<Map<String, dynamic>> promoSlides = [
      {'image': 'assets/slide/gambar1.jpg'},
      {'image': 'assets/slide/gambar2.jpg'},
      {'image': 'assets/slide/gambar3.jpg'},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meneruskan fungsi navigasi ke header
          _HeaderAndSearch(onBagTap: _navigateToCheckout),
          const SizedBox(height: 5),
          // Meneruskan data slide ke _PromoCard
          _PromoCard(promoSlides: promoSlides),
          const SizedBox(height: 20),
          _TwoColumnCategoryTabs(
            selectedCategory: _selectedCategory,
            // Kategori Tabs kembali berfungsi normal (mengubah state)
            onCategoryTapped: _updateCategory,
          ),
          // LANGKAH 3: Teruskan fungsi navigasi ke _HomeListGrid
          _HomeListGrid(
            menu: _currentMenu,
            currentCategory: _selectedCategory,
            onItemTap:
                _navigateToDetail, // <-- DIPERBAIKI: Meneruskan fungsi navigasi
          ),
        ],
      ),
    );
  }

  // ... (Bagian lain dari _HomeViewState)
  List<Widget> get _dynamicWidgetOptions => <Widget>[
    _buildHomeContent(), // Index 0: Konten Home
    const PromoView(), // Index 1
    const PoinView(), // Index 2
    const ProfileView(), // Index 3
  ];

  @override
  void initState() {
    super.initState();
    _setSystemUIColors();
  }

  void _setSystemUIColors() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: _kBackgroundColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _kBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _selectedCategory = MenuCategory.nearest;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: _dynamicWidgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// === WIDGET KOMPONEN UI ===
// Semua kode di bawah ini (kecuali yang dihapus di akhir) TIDAK DIUBAH.

class _HeaderAndSearch extends StatelessWidget {
  final VoidCallback? onBagTap;
  const _HeaderAndSearch({this.onBagTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(color: _kBackgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Text(
                        'Bilzen, Tanjungbalai',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Ionicons.chevron_down_outline, color: Colors.black),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: onBagTap,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: _kSearchBarColor,
                  child: Icon(Ionicons.bag_outline, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: const TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Ionicons.search_outline,
                      color: Colors.black54,
                    ),
                    hintText: 'Search coffee',
                    hintStyle: TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: _kSearchBarColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _kAccentColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Ionicons.filter_outline, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
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
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        if (_currentPage < widget.promoSlides.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeIn,
          );
        }
      }
    });
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.promoSlides.length,
                itemBuilder: (context, index) {
                  final slide = widget.promoSlides[index];
                  return Image.asset(
                    slide['image'] as String,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: Text(
                            'Promo Image Not Found',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              Positioned(
                bottom: 10,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.promoSlides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: _currentPage == index ? 24.0 : 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(4.0),
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
  final ValueChanged<MenuCategory> onCategoryTapped;

  const _TwoColumnCategoryTabs({
    required this.selectedCategory,
    required this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _kBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _kCategoryBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _CategoryButton(
                text: 'Terdekat',
                isSelected: selectedCategory == MenuCategory.nearest,
                onTap: () => onCategoryTapped(MenuCategory.nearest),
              ),
            ),
            Expanded(
              child: _CategoryButton(
                text: 'Favorit',
                isSelected: selectedCategory == MenuCategory.favorite,
                onTap: () => onCategoryTapped(MenuCategory.favorite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? _kSelectedCategoryColor : _kCategoryUnselectedBg,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(color: _kCategoryBorderColor, width: 0.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _HomeListGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menu;
  final MenuCategory currentCategory;
  final void Function(Map<String, dynamic>) onItemTap;

  const _HomeListGrid({
    required this.menu,
    required this.currentCategory,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'Tidak ada item dalam kategori ini.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menu.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final itemData = menu[index];
        return _HomeCard(
          item: itemData,
          isFavoriteCategory: currentCategory == MenuCategory.favorite,
          onTap: () => onItemTap(itemData),
        );
      },
    );
  }
}

class _HomeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFavoriteCategory;
  final VoidCallback onTap;

  const _HomeCard({
    required this.item,
    required this.isFavoriteCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // MODIFIKASI: actionIcon sekarang adalah nullable dan hanya diisi jika kategori Favorit
    final IconData? actionIcon = isFavoriteCategory
        ? Ionicons
              .trash_outline // Ikon Sampah untuk Favorit
        : null; // Null (tidak ada ikon aksi) untuk Terdekat

    void onActionTapped() {
      if (isFavoriteCategory) {
        debugPrint('Hapus ${item['name']} dari Favorit');
      } else {
        // Logika ini tidak akan dipicu karena tombol dihilangkan,
        // tapi log tetap ada untuk kejelasan.
        debugPrint(
          'Tidak ada aksi tambahan untuk ${item['name']} di kategori Terdekat',
        );
      }
    }

    // <-- PERBAIKAN DI SINI: Atur aksi klik kartu berdasarkan kategori.
    // Jika di kategori Favorit, set aksi klik seluruh kartu ke null (tidak bisa diklik untuk navigasi).
    final VoidCallback? cardTapAction = isFavoriteCategory ? null : onTap;

    // Bungkus seluruh Container dengan GestureDetector/InkWell
    return GestureDetector(
      onTap: cardTapAction, // Memanggil cardTapAction yang sudah dikondisikan
      child: Container(
        decoration: BoxDecoration(
          color: _kSearchBarColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Image.asset(
                    item['image']!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: item['color'] as Color,
                      child: const Center(
                        child: Text(
                          'Image',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Ionicons.star,
                          color: _kAccentColor,
                          size: 14,
                        ),
                        Text(
                          '${item['rating']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    item['type']!,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$ ${item['price']!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // KONDISI BARU: Tombol aksi hanya ditampilkan jika actionIcon tidak null
                      if (actionIcon != null)
                        GestureDetector(
                          onTap: onActionTapped, // HANYA memicu aksi hapus
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isFavoriteCategory
                                  ? Colors.red
                                  : _kAccentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(actionIcon, color: Colors.white),
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
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: _kBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Ionicons.home_outline, Ionicons.home, onTap),
            _buildNavItem(
              1,
              Ionicons.pricetags_outline,
              Ionicons.pricetags,
              onTap,
            ),
            _buildNavItem(2, Ionicons.wallet_outline, Ionicons.wallet, onTap),
            _buildNavItem(3, Ionicons.person_outline, Ionicons.person, onTap),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    Function(int) onTap,
  ) {
    final bool isSelected = selectedIndex == index;
    return IconButton(
      icon: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        color: isSelected ? _kAccentColor : Colors.black,
        size: 28,
      ),
      onPressed: () => onTap(index),
    );
  }
}
