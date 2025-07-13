import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../parfum/parfum_page.dart';
import '../location_map/location_map_page.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchText = '';
  bool _showSearch = false;
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchSlideAnimation;

  final List<Widget> _widgetOptions = [
    const Center(child: Text('Halaman Transaksi (belum diimplementasikan)')),
    const LocationMapPage(),
    const ParfumPage(),
  ];

  final List<String> _pageTitles = [
    'Transaksi',
    'Peta Lokasi',
    'Parfum Store',
  ];

  final List<IconData> _pageIcons = [
    Icons.receipt_long_rounded,
    Icons.location_on_rounded,
    Icons.shopping_bag_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _searchSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index != _selectedIndex) {
      // Haptic feedback untuk pengalaman yang lebih baik
      HapticFeedback.lightImpact();
      
      // Reset search ketika pindah tab
      if (_showSearch) {
        setState(() => _showSearch = false);
        _searchAnimationController.reverse();
      }
      
      setState(() {
        _selectedIndex = index;
      });
      
      // Reset dan mulai animasi lagi
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (_showSearch) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
    HapticFeedback.lightImpact();
  }

  Widget _buildAppBarTitle() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _pageIcons[_selectedIndex],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _pageTitles[_selectedIndex],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Dashboard Admin',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _searchSlideAnimation.value) * -50),
          child: Opacity(
            opacity: _searchSlideAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: TextEditingController(text: _searchText),
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Cari parfum...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() => _searchText = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) => setState(() => _searchText = value),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBody() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
          )),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _widgetOptions[_selectedIndex],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: isSelected ? 26 : 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isSelected ? 12 : 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              letterSpacing: 0.3,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFF6B73FF),
                Color(0xFF9A9CE3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: _buildAppBarTitle(),
        actions: [
          if (_selectedIndex == 2)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: AnimatedRotation(
                        turns: _showSearch ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _showSearch ? Icons.close_rounded : Icons.search_rounded,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _toggleSearch,
                    ),
                  ),
                );
              },
            ),
        ],
        bottom: _showSearch && _selectedIndex == 2
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: _buildSearchBar(),
              )
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
              Color(0xFFF8F9FA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildAnimatedBody(),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFF6B73FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onBottomNavTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.6),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: _buildBottomNavItem(0, Icons.receipt_long_rounded, 'Transaksi'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildBottomNavItem(1, Icons.location_on_rounded, 'Peta Lokasi'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildBottomNavItem(2, Icons.shopping_bag_rounded, 'Parfum'),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}