import '../../models/catalog_item_model.dart';

abstract interface class CatalogLocalDataSource {
  Future<List<CatalogItemModel>> getCachedCatalogItems(String shopId);
  Future<void> cacheCatalogItems(
    String shopId,
    List<CatalogItemModel> items,
  );

  Future<List<CatalogItemModel>> getCachedFeaturedItems({
    String? type,
    int? limit,
  });
  Future<void> cacheFeaturedItems(List<CatalogItemModel> items);
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
        image: 'https://picsum.photos/seed/bath-grooming/400',
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
        image: 'https://picsum.photos/seed/haircut-styling/400',
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
        image: 'https://picsum.photos/seed/overnight-boarding/400',
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
        image: 'https://picsum.photos/seed/meds-care/400',
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
        image: 'https://picsum.photos/seed/full-day-daycare/400',
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
        image: 'https://picsum.photos/seed/dog-walking/400',
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
        image: 'https://picsum.photos/seed/premium-kibble/400',
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
        image: 'https://picsum.photos/seed/travel-carrier/400',
        category: 'pet_shop',
      ),
    ],
  };

  // Cross-shop "Featured Products" fallback — seeded independently of
  // _cache above so the home-screen grid has something to render even
  // before /user/catalog-items has ever answered successfully.
  List<CatalogItemModel> _featuredCache = const [
    CatalogItemModel(
      itemId: 'item_food_bag',
      shopId: 'shop_pawmart',
      itemType: 'product',
      name: 'Premium Kibble (5kg)',
      description: 'Grain-free, all life stages.',
      priceFrom: 35,
      icon: 'bone',
      color: '#F5EDE6',
      image: 'https://picsum.photos/seed/premium-kibble/400',
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
      image: 'https://picsum.photos/seed/travel-carrier/400',
      category: 'pet_shop',
    ),
    CatalogItemModel(
      itemId: 'item_chew_toy',
      shopId: 'shop_pawmart',
      itemType: 'product',
      name: 'Rope Chew Toy',
      description: 'Durable cotton rope, tug-tested.',
      priceFrom: 8,
      icon: 'bone',
      color: '#EDE8F5',
      image: 'https://picsum.photos/seed/rope-chew-toy/400',
      category: 'pet_shop',
    ),
    CatalogItemModel(
      itemId: 'item_pet_bed',
      shopId: 'shop_pawmart',
      itemType: 'product',
      name: 'Orthopedic Pet Bed',
      description: 'Memory-foam support, washable cover.',
      priceFrom: 55,
      icon: 'bed',
      color: '#F2E8E0',
      image: 'https://picsum.photos/seed/pet-bed/400',
      category: 'pet_shop',
    ),
    CatalogItemModel(
      itemId: 'item_leash_set',
      shopId: 'shop_pawmart',
      itemType: 'product',
      name: 'Leash & Collar Set',
      description: 'Reflective stitching, adjustable fit.',
      priceFrom: 22,
      icon: 'walk',
      color: '#E8F0EE',
      image: 'https://picsum.photos/seed/leash-collar-set/400',
      category: 'pet_shop',
    ),
    CatalogItemModel(
      itemId: 'item_grooming_kit',
      shopId: 'shop_bark_bath',
      itemType: 'product',
      name: 'Home Grooming Kit',
      description: 'Brush, nail clipper, and shampoo bundle.',
      priceFrom: 28,
      icon: 'scissors',
      color: '#F5EDE6',
      image: 'https://picsum.photos/seed/grooming-kit/400',
      category: 'grooming',
    ),
  ];

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

  @override
  Future<List<CatalogItemModel>> getCachedFeaturedItems({
    String? type,
    int? limit,
  }) async {
    var items = _featuredCache;
    if (type != null) {
      items = items.where((item) => item.itemType == type).toList();
    }
    if (limit != null && limit < items.length) {
      items = items.sublist(0, limit);
    }
    return List.unmodifiable(items);
  }

  @override
  Future<void> cacheFeaturedItems(List<CatalogItemModel> items) async {
    _featuredCache = items;
  }
}
