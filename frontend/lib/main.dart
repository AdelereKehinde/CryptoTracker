import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/market_overview_screen.dart';
import 'screens/trending_coins_screen.dart';
import 'screens/search_screen.dart';
import 'screens/category_explorer_screen.dart';
import 'screens/blockchain_explorer_screen.dart';
import 'screens/coin_detail_screen.dart';
import 'screens/coin_exchanges_screen.dart';
import 'screens/token_detail_screen.dart';
import 'screens/social_links_screen.dart';
import 'screens/add_to_watchlist_modal.dart';
import 'screens/portfolio_overview_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/portfolio_history_screen.dart';
import 'screens/add_holding_screen.dart';
import 'screens/price_chart_screen.dart';
import 'screens/custom_range_chart_screen.dart';
import 'screens/token_chart_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/news_feed_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_panel_screen.dart';

void main() {
  runApp(MaterialApp(
    title: 'Cheese_Ball',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0D47A1),
    ),
    initialRoute: '/splash',
    routes: {
      '/splash': (_) => SplashScreen(),
      '/onboarding': (_) => OnboardingScreen(),
      '/login': (_) => LoginScreen(),
      '/signup': (_) => SignupScreen(),
      '/main_dashboard': (_) => MainDashboardScreen(),
      '/dashboard': (_) => HomeDashboardScreen(),
      '/market': (_) => MarketOverviewScreen(),
      '/trending': (_) => TrendingCoinsScreen(),
      '/search': (_) => SearchScreen(),
      '/categories': (_) => CategoryExplorerScreen(),
      '/blockchain': (_) => BlockchainExplorerScreen(),
      '/coin_detail': (_) => CoinDetailScreen(),
      '/coin_exchanges': (_) => CoinExchangesScreen(),
      '/token_detail': (_) => TokenDetailScreen(),
      '/social_links': (_) => SocialLinksScreen(),
      '/add_to_watchlist': (_) => AddToWatchlistModal(),
      '/portfolio': (_) => PortfolioOverviewScreen(),
      '/watchlist': (_) => WatchlistScreen(),
      '/portfolio_history': (_) => PortfolioHistoryScreen(),
      '/add_holding': (_) => AddHoldingScreen(),
      '/price_chart': (_) => PriceChartScreen(),
      '/custom_range_chart': (_) => CustomRangeChartScreen(),
      '/token_chart': (_) => TokenChartScreen(),
      '/analytics_dashboard': (_) => AnalyticsDashboardScreen(),
      '/news_feed': (_) => NewsFeedScreen(),
      '/notifications': (_) => NotificationsScreen(),
      '/community': (_) => CryptoDashboard(),
      '/profile': (_) => ProfileScreen(),
      '/settings': (_) => SettingsScreen(),
      '/admin_login': (_) => AdminLoginScreen(),
      '/admin_panel': (_) => AdminPanelScreen(),
    },
  ));
}