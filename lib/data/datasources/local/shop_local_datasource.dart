import '../../models/shop_model.dart';

abstract interface class ShopLocalDataSource {
  Future<List<ShopModel>> getCachedShops();
  Future<void> cacheShops(List<ShopModel> shops);
}

class ShopLocalDataSourceImpl implements ShopLocalDataSource {
  // Seeded with dev mock data; cleared and replaced once the shops API responds.
  final List<ShopModel> _cache = [
    const ShopModel(
      shopId: 'shop_bark_bath',
      name: 'Bark & Bath Grooming',
      description: 'Full-service grooming for dogs and cats of every coat.',
      logo: '',
      contactEmail: 'hello@barkbath.test',
      contactPhone: '555-0101',
      hours: 'Mon–Sat 9am–6pm',
      status: 'active',
      categoryId: 'cat_grooming',
    ),
    const ShopModel(
      shopId: 'shop_cozy_paws',
      name: 'Cozy Paws Boarding',
      description: 'Overnight boarding with a home-away-from-home feel.',
      logo: '',
      contactEmail: 'stay@cozypaws.test',
      contactPhone: '555-0102',
      hours: 'Open 24/7',
      status: 'active',
      categoryId: 'cat_boarding',
    ),
    const ShopModel(
      shopId: 'shop_wagging_tails',
      name: 'Wagging Tails Daycare',
      description: 'Supervised play and enrichment while you’re away.',
      logo: '',
      contactEmail: 'play@waggingtails.test',
      contactPhone: '555-0103',
      hours: 'Mon–Fri 7am–7pm',
      status: 'active',
      categoryId: 'cat_daycare',
    ),
    const ShopModel(
      shopId: 'shop_pawmart',
      name: 'PawMart Supplies',
      description: 'Food, toys and accessories for the whole family.',
      logo: '',
      contactEmail: 'orders@pawmart.test',
      contactPhone: '555-0104',
      hours: 'Daily 8am–9pm',
      status: 'active',
      categoryId: 'cat_pet_shop',
    ),
  ];

  @override
  Future<List<ShopModel>> getCachedShops() async => List.unmodifiable(_cache);

  @override
  Future<void> cacheShops(List<ShopModel> shops) async {
    _cache
      ..clear()
      ..addAll(shops);
  }
}
