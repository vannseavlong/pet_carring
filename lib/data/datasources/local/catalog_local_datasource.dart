import '../../models/catalog_item_model.dart';

abstract interface class CatalogLocalDataSource {
  Future<List<CatalogItemModel>> getCachedCatalogItems(String shopId);
  Future<void> cacheCatalogItems(
    String shopId,
    List<CatalogItemModel> items,
  );
}

class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  // Seeded with dev mock data, keyed by shop_id; cleared and replaced per-shop
  // once the catalog-items API responds.
  final Map<String, List<CatalogItemModel>> _cache = {
    'shop_bark_bath': const [
      CatalogItemModel(
        itemId: 'item_bath_grm',
        shopId: 'shop_bark_bath',
        itemType: 'service',
        name: 'Bath & Grooming',
        description: 'A full wash, blow-dry and brush-out.',
        priceFrom: 25,
        icon: 'bath',
        color: '#E8F0EE',
        category: 'grooming',
      ),
      CatalogItemModel(
        itemId: 'item_haircut',
        shopId: 'shop_bark_bath',
        itemType: 'service',
        name: 'Haircut & Styling',
        description: 'Breed-standard or custom trim.',
        priceFrom: 30,
        icon: 'scissors',
        color: '#F5EDE6',
        category: 'grooming',
      ),
    ],
    'shop_cozy_paws': const [
      CatalogItemModel(
        itemId: 'item_overnight_stay',
        shopId: 'shop_cozy_paws',
        itemType: 'service',
        name: 'Overnight Boarding',
        description: 'A comfy suite with daily check-ins.',
        priceFrom: 40,
        icon: 'bone',
        color: '#EDE8F5',
        category: 'boarding',
      ),
      CatalogItemModel(
        itemId: 'item_meds',
        shopId: 'shop_cozy_paws',
        itemType: 'service',
        name: 'Meds & Care',
        description: 'Administering prescribed medication.',
        priceFrom: 10,
        icon: 'medicine',
        color: '#EDE8F5',
        category: 'boarding',
      ),
    ],
    'shop_wagging_tails': const [
      CatalogItemModel(
        itemId: 'item_daycare',
        shopId: 'shop_wagging_tails',
        itemType: 'service',
        name: 'Full-Day Daycare',
        description: 'Supervised play and enrichment.',
        priceFrom: 20,
        icon: 'play',
        color: '#E8F0EE',
        category: 'daycare',
      ),
      CatalogItemModel(
        itemId: 'item_walk',
        shopId: 'shop_wagging_tails',
        itemType: 'service',
        name: 'Dog Walking',
        description: 'A loop around the neighborhood.',
        priceFrom: 15,
        icon: 'walk',
        color: '#F5EDE6',
        category: 'daycare',
      ),
    ],
    'shop_pawmart': const [
      CatalogItemModel(
        itemId: 'item_food_bag',
        shopId: 'shop_pawmart',
        itemType: 'product',
        name: 'Premium Kibble (5kg)',
        description: 'Grain-free, all life stages.',
        priceFrom: 35,
        icon: 'bone',
        color: '#F5EDE6',
        category: 'pet_shop',
      ),
      CatalogItemModel(
        itemId: 'item_travel_carrier',
        shopId: 'shop_pawmart',
        itemType: 'product',
        name: 'Travel Carrier',
        description: 'Airline-approved soft-sided carrier.',
        priceFrom: 45,
        icon: 'car',
        color: '#E8F0EE',
        category: 'pet_shop',
      ),
    ],
  };

  @override
  Future<List<CatalogItemModel>> getCachedCatalogItems(String shopId) async =>
      List.unmodifiable(_cache[shopId] ?? const []);

  @override
  Future<void> cacheCatalogItems(
    String shopId,
    List<CatalogItemModel> items,
  ) async {
    _cache[shopId] = items;
  }
}
