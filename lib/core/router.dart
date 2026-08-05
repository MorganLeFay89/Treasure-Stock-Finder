import 'package:go_router/go_router.dart';
import 'package:finance/features/stock_search/presentation/pages/home_page.dart';
import 'package:finance/features/stock_search/presentation/pages/search_results_page.dart';
import 'package:finance/features/stock_detail/presentation/pages/stock_detail_page.dart';
import 'package:finance/features/favorite/presentation/pages/favorite_page.dart';
import 'package:finance/features/search_history/presentation/pages/search_history_page.dart';
import 'package:finance/features/api_settings/presentation/pages/api_settings_page.dart';
import 'package:finance/features/stock_search/domain/stock.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/search_results',
      builder: (context, state) => const SearchResultsPage(),
    ),
    GoRoute(
      path: '/stock_detail',
      builder: (context, state) {
        final stock = state.extra as Stock;
        return StockDetailPage(stock: stock);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritePage(),
    ),
    GoRoute(
      path: '/search_history',
      builder: (context, state) => const SearchHistoryPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ApiSettingsPage(),
    ),
  ],
);
