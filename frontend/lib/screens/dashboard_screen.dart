import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'home_dashboard_screen.dart';
import 'market_overview_screen.dart';
import 'news_feed_screen.dart';
import 'watchlist_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> 
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://cryptotracker-yof6.onrender.com/'));
  List topCoins = [];
  bool loadingCoins = true;
  int _selectedIndex = 0;
  late AnimationController _pulseController;

  // Fixed color definitions - using const Color() to ensure they're properly initialized
  static const Color _darkBlue = Color(0xFF0A0E2A);
  static const Color _mediumBlue = Color(0xFF1A237E);
  static const Color _lightBlue = Color(0xFF3949AB);
  static const Color _accentBlue = Color(0xFF2979FF);
  static const Color _tealAccent = Color(0xFF1DE9B6);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _white70 = Color(0xB3FFFFFF);
  static const Color _white54 = Color(0x8AFFFFFF);
  static const Color _white30 = Color(0x4DFFFFFF);
  static const Color _white10 = Color(0x1AFFFFFF);

  // Updated tabs - Profile replaced with Watchlist
  final List<Widget> _tabs = [
    HomeDashboardScreen(),
    MarketOverviewScreen(),
    NewsFeedScreen(),
    WatchlistScreen(), // Replaced ProfileScreen
  ];

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for trending icons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fetchTopCoins();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchTopCoins() async {
    setState(() => loadingCoins = true);
    try {
      final resp = await _dio.get('/coins/markets', queryParameters: {
        'vs_currency': 'usd', 
        'order': 'market_cap_desc', 
        'per_page': 10, 
        'page': 1
      });
      topCoins = resp.data ?? [];
    } catch (e) {
      topCoins = [];
    } finally {
      setState(() => loadingCoins = false);
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  // Enhanced top coins with blue theme and animations
  Widget _buildTopCoins() {
    if (loadingCoins) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentBlue),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: topCoins.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final coin = topCoins[index];
          final imageUrl = (coin['image'] is String) 
              ? coin['image'] 
              : (coin['image'] is Map 
                  ? (coin['image']['small'] ?? coin['image']['thumb'] ?? '') 
                  : '');
          
          final priceChange = coin['price_change_percentage_24h'] ?? 0;
          final isPositive = priceChange >= 0;

          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/coin_detail', arguments: coin['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: 170,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _accentBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: _white10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coin header with animated icon
                  Row(
                    children: [
                      Hero(
                        tag: 'coin-image-${coin['id']}',
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: _white,
                          backgroundImage: imageUrl.isNotEmpty 
                              ? NetworkImage(imageUrl) 
                              : null,
                          child: imageUrl.isEmpty 
                              ? Icon(Icons.currency_bitcoin, 
                                  color: _darkBlue, size: 16) 
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${coin['symbol']?.toUpperCase() ?? ''}',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, child) {
                          return Transform.scale(
                            scale: 1 + (_pulseController.value * 0.2),
                            child: Icon(
                              isPositive ? Icons.trending_up : Icons.trending_down,
                              color: isPositive ? _tealAccent : Colors.redAccent,
                              size: 18,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Price information
                  Text(
                    '\$${coin['current_price']?.toStringAsFixed(2) ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Percentage change
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive 
                          ? _tealAccent.withOpacity(0.2) 
                          : Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${priceChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? _tealAccent : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Enhanced quick actions grid with animations
  Widget _buildQuickGrid() {
    final tiles = [
      {'title': 'Markets', 'icon': Icons.show_chart, 'route': '/market'},
      {'title': 'Portfolio', 'icon': Icons.pie_chart, 'route': '/portfolio'},
      {'title': 'Watchlist', 'icon': Icons.star, 'route': '/watchlist'},
      {'title': 'Analytics', 'icon': Icons.analytics, 'route': '/analytics_dashboard'},
      {'title': 'Exchanges', 'icon': Icons.swap_horiz, 'route': '/coin_exchanges'},
      {'title': 'News', 'icon': Icons.article, 'route': '/news_feed'},
      {'title': 'Charts', 'icon': Icons.forum, 'route': '/community'},
      {'title': 'Settings', 'icon': Icons.settings, 'route': '/settings'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: tiles.map((tile) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, tile['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _accentBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tile['icon'] as IconData, 
                  color: _tealAccent, 
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  tile['title'] as String, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.currency_bitcoin, color: _tealAccent, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Cheese_Ball', 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'), 
            icon: Icon(Icons.search, color: _white70),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'), 
            icon: Icon(Icons.notifications_outlined, color: _white70),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Enhanced search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _white10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search, color: _white54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search coins, tickers or tokens', 
                        style: TextStyle(color: _white54),
                      ),
                    ),
                    Container(
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: _accentBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/market'),
                        child: const Text(
                          'Explore', 
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Top coins section
            _buildTopCoins(),
            const SizedBox(height: 16),
            // Main content area with IndexedStack for static navigation
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0A0E2A),
                ),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _tabs,
                ),
              ),
            ),
          ],
        ),
      ),
      // Static bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _mediumBlue,
          border: Border(top: BorderSide(color: _white10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: _tealAccent,
            unselectedItemColor: _white70,
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Market',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Watchlist',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentBlue,
        child: Icon(Icons.add, color: _white),
        onPressed: () => showModalBottomSheet(
          context: context, 
          builder: (_) => _quickActionsSheet(),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _quickActionsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E2A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick Actions', 
            style: TextStyle(
              fontSize: 18, 
              color: Colors.white, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}