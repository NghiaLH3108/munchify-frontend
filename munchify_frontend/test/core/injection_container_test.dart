import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/injection_container.dart' as di;
import 'package:munchify_frontend/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:munchify_frontend/features/pos/domain/repositories/promotion_repository.dart' as pos_promo;
import 'package:munchify_frontend/features/products/domain/usecases/get_products_usecase.dart' as admin_products;
import 'package:munchify_frontend/features/pos/domain/usecases/get_products_usecase.dart' as pos_products;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Injection Container Disambiguation Tests', () {
    test('DI registers both Admin and POS Promotion repositories without collision', () async {
      await di.sl.reset();
      await di.init();

      // Verify that both repositories are registered under their distinct types
      expect(di.sl.isRegistered<PromotionRepository>(), isTrue,
          reason: 'Admin PromotionRepository must be registered');
      expect(di.sl.isRegistered<pos_promo.PromotionRepository>(), isTrue,
          reason: 'POS PromotionRepository must be registered via alias');

      // Verify that both GetProductsUseCase are registered under their distinct types
      expect(di.sl.isRegistered<admin_products.GetProductsUseCase>(), isTrue,
          reason: 'Admin GetProductsUseCase must be registered');
      expect(di.sl.isRegistered<pos_products.GetProductsUseCase>(), isTrue,
          reason: 'POS GetProductsUseCase must be registered');
    });
  });
}
