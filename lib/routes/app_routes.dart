import 'package:flutter/material.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/dashboard/admin_dashboard_page.dart'; // Import DashboardAdminPage
import '../presentation/dashboard/user_dashboard_page.dart'; // Pastikan ini juga diimpor dengan path yang benar
import '../presentation/parfum/parfum_page.dart'; 
import '../presentation/location_map/location_map_page.dart';// Import ParfumPage;




class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/": // Biasanya ini adalah initial route, mengarah ke login
        return MaterialPageRoute(builder: (_) => LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case "/pelanggan": // Mungkin ini untuk user biasa
        return MaterialPageRoute(builder: (_) => DashboardUserPage());
      case "/admin": // Rute untuk Dashboard Admin
        return MaterialPageRoute(builder: (_) => const DashboardAdminPage());
      case "/parfum": // Rute untuk halaman Manajemen Parfum
        // Pastikan ParfumBloc tersedia di sini jika ParfumPage tidak memanggilnya sendiri
        // Atau, yang lebih baik adalah menggunakan MultiBlocProvider di main.dart
        // dan ParfumPage akan menggunakan context.read<ParfumBloc>()
        return MaterialPageRoute(builder: (_) => const ParfumPage());
      case "/location":
        return MaterialPageRoute(builder: (_) => const LocationMapPage());
      default:
        return MaterialPageRoute(builder: (_) => const Text("Error: Rute tidak ditemukan!"));
    }
  }
}