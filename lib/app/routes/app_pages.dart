import 'package:get/get.dart';

import '../modules/Poin/bindings/poin_binding.dart';
import '../modules/Poin/views/poin_view.dart';
import '../modules/Profile/bindings/profile_binding.dart';
import '../modules/Profile/views/profile_view.dart';
import '../modules/Scanner/bindings/scanner_binding.dart';
import '../modules/Scanner/views/scanner_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/detail_menu/bindings/detail_menu_binding.dart';
import '../modules/detail_menu/views/detail_menu_view.dart';
import '../modules/detail_poin/bindings/detail_poin_binding.dart';
import '../modules/detail_poin/views/detail_poin_view.dart';
import '../modules/detailpesanansaya/bindings/detailpesanansaya_binding.dart';
import '../modules/detailpesanansaya/views/detailpesanansaya_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/keamananakun/bindings/keamananakun_binding.dart';
import '../modules/keamananakun/views/keamananakun_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/lupapassword/bindings/lupapassword_binding.dart';
import '../modules/lupapassword/views/lupapassword_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/pesanansaya/bindings/pesanansaya_binding.dart';
import '../modules/pesanansaya/views/pesanansaya_view.dart';
import '../modules/promo/bindings/promo_binding.dart';
import '../modules/promo/views/promo_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/verifikasi/bindings/verifikasi_binding.dart';
import '../modules/verifikasi/views/verifikasi_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.VERIFIKASI;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.PROMO,
      page: () => const PromoView(),
      binding: PromoBinding(),
    ),
    GetPage(
      name: _Paths.POIN,
      page: () => const PoinView(),
      binding: PoinBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_POIN,
      page: () => const DetailPoinView(),
      binding: DetailPoinBinding(),
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_MENU,
      page: () => const DetailMenuView(),
      binding: DetailMenuBinding(),
    ),
    GetPage(
      name: _Paths.VERIFIKASI,
      page: () => const VerifikasiView(),
      binding: VerifikasiBinding(),
    ),
    GetPage(
      name: _Paths.KEAMANANAKUN,
      page: () => const KeamananakunView(),
      binding: KeamananakunBinding(),
    ),
    GetPage(
      name: _Paths.LUPAPASSWORD,
      page: () => const LupapasswordView(),
      binding: LupapasswordBinding(),
    ),
    GetPage(
      name: _Paths.PESANANSAYA,
      page: () => const PesanansayaView(),
      binding: PesanansayaBinding(),
    ),
    GetPage(
      name: _Paths.DETAILPESANANSAYA,
      page: () => const DetailpesanansayaView(),
      binding: DetailpesanansayaBinding(),
    ),
    GetPage(
      name: _Paths.SCANNER,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
    ),
  ];
}
