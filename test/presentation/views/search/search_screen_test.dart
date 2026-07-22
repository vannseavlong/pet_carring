import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pet_carrying_app/domain/entities/catalog_item.dart';
import 'package:pet_carrying_app/domain/entities/category.dart';
import 'package:pet_carrying_app/domain/entities/shop.dart';
import 'package:pet_carrying_app/domain/repositories/catalog_repository.dart';
import 'package:pet_carrying_app/domain/repositories/category_repository.dart';
import 'package:pet_carrying_app/domain/repositories/shop_repository.dart';
import 'package:pet_carrying_app/domain/usecases/get_catalog_items_usecase.dart';
import 'package:pet_carrying_app/domain/usecases/get_categories_usecase.dart';
import 'package:pet_carrying_app/domain/usecases/get_featured_catalog_items_usecase.dart';
import 'package:pet_carrying_app/domain/usecases/get_shops_usecase.dart';
import 'package:pet_carrying_app/presentation/controllers/category_controller.dart';
import 'package:pet_carrying_app/presentation/controllers/shop_controller.dart';
import 'package:pet_carrying_app/presentation/views/search/search_screen.dart';

class _FakeShopRepository implements ShopRepository {
  @override
  Future<List<Shop>> getShops() async => const [
        Shop(
          shopId: 's1',
          name: 'Happy Paws Grooming',
          description: 'Full-service grooming',
          logo: '',
          contactEmail: '',
          contactPhone: '',
          hours: '',
          status: 'active',
          categoryId: 'grooming',
        ),
        Shop(
          shopId: 's2',
          name: 'Cozy Boarding House',
          description: 'Overnight pet boarding',
          logo: '',
          contactEmail: '',
          contactPhone: '',
          hours: '',
          status: 'active',
          categoryId: 'boarding',
        ),
      ];

  @override
  Future<Shop> getShopById(String shopId) async => throw UnimplementedError();
}

class _FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<CatalogItem>> getCatalogItems(String shopId) async => const [];

  @override
  Future<List<CatalogItem>> getFeaturedItems({String? type, int? limit}) async => const [];
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async => const [
        Category(categoryId: 'grooming', name: 'Grooming', icon: '🛁', sortOrder: 1),
        Category(categoryId: 'boarding', name: 'Boarding', icon: '🏡', sortOrder: 2),
      ];
}

Widget _wrap(Widget child) => GetMaterialApp(home: child);

void main() {
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    final repo = _FakeShopRepository();
    final catalogRepo = _FakeCatalogRepository();
    Get.put<ShopController>(
      ShopController(
        GetShopsUseCase(repo),
        GetCatalogItemsUseCase(catalogRepo),
        GetFeaturedCatalogItemsUseCase(catalogRepo),
      ),
    );
    Get.put<CategoryController>(
      CategoryController(GetCategoriesUseCase(_FakeCategoryRepository())),
    );
  });

  tearDown(Get.reset);

  testWidgets('empty query shows the no-error empty state, not a GetX crash', (tester) async {
    await tester.pumpWidget(_wrap(const SearchScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.textContaining('improper use'), findsNothing);
  });

  testWidgets('filter icon opens a bottom sheet with category chips', (tester) async {
    await tester.pumpWidget(_wrap(const SearchScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Filter by category'), findsOneWidget);
    expect(find.textContaining('Grooming'), findsWidgets);
    expect(find.textContaining('Boarding'), findsWidgets);
  });

  testWidgets('selecting a category filters results and shows the badge', (tester) async {
    await tester.pumpWidget(_wrap(const SearchScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Grooming').last);
    await tester.pumpAndSettle();

    expect(find.text('Happy Paws Grooming'), findsOneWidget);
    expect(find.text('Cozy Boarding House'), findsNothing);
  });

  testWidgets('typing a query searches by name', (tester) async {
    await tester.pumpWidget(_wrap(const SearchScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'cozy');
    await tester.pumpAndSettle();

    expect(find.text('Cozy Boarding House'), findsOneWidget);
    expect(find.text('Happy Paws Grooming'), findsNothing);
  });

  testWidgets('submitting a search saves it to recent searches', (tester) async {
    await tester.pumpWidget(_wrap(const SearchScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'cozy');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('cozy'), findsOneWidget);
  });
}
