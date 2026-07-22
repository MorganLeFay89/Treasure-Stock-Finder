import 'package:go_router/go_router.dart';
import 'package:finance/features/stock_search/presentation/pages/home_page.dart';
import 'package:finance/features/stock_search/presentation/pages/search_results_page.dart';
import 'package:finance/features/stock_detail/presentation/pages/stock_detail_page.dart';
import 'package:finance/features/favorite/presentation/pages/favorite_page.dart';
import 'package:finance/features/stock_search/domain/stock.dart';

// Phase 1 MVPでは HomePage と 検索結果、詳細 へのルーティングを定義します
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
  ],
);
