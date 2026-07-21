import 'package:get/get.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/shop.dart';
import '../../domain/usecases/get_catalog_items_usecase.dart';
import '../../domain/usecases/get_featured_catalog_items_usecase.dart';
import '../../domain/usecases/get_shops_usecase.dart';
import 'booking_controller.dart' show ViewState;

class ShopController extends GetxController {
  final GetShopsUseCase _getShops;
  final GetCatalogItemsUseCase _getCatalogItems;
  final GetFeaturedCatalogItemsUseCase _getFeaturedCatalogItems;

  ShopController(
    this._getShops,
    this._getCatalogItems,
    this._getFeaturedCatalogItems,
  );

  final RxList<Shop> shops = <Shop>[].obs;
  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString errorMessage = ''.obs;

  final RxList<CatalogItem> selectedShopCatalog = <CatalogItem>[].obs;
  final Rx<ViewState> catalogState = ViewState.idle.obs;

  final RxList<CatalogItem> featuredProducts = <CatalogItem>[].obs;
  final Rx<ViewState> featuredProductsState = ViewState.idle.obs;

  bool get isLoading => state.value == ViewState.loading;
  bool get isLoadingCatalog => catalogState.value == ViewState.loading;
  bool get isLoadingFeaturedProducts =>
      featuredProductsState.value == ViewState.loading;

  @override
  void onInit() {
    super.onInit();
    fetchShops();
    fetchFeaturedProducts();
  }

  Future<void> fetchShops() async {
    state.value = ViewState.loading;
    try {
      shops.value = await _getShops();
      state.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
    }
  }

  Future<void> fetchFeaturedProducts() async {
    featuredProductsState.value = ViewState.loading;
    try {
      featuredProducts.value = await _getFeaturedCatalogItems(
        type: CatalogItemType.product,
        limit: 6,
      );
      featuredProductsState.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      featuredProductsState.value = ViewState.error;
    }
  }

  Future<void> fetchCatalogItems(String shopId) async {
    catalogState.value = ViewState.loading;
    try {
      selectedShopCatalog.value = await _getCatalogItems(shopId);
      catalogState.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      catalogState.value = ViewState.error;
    }
  }

  Shop? shopById(String shopId) {
    for (final shop in shops) {
      if (shop.shopId == shopId) return shop;
    }
    return null;
  }

  List<Shop> search({String query = '', String? category}) {
    final normalized = query.trim().toLowerCase();
    return shops.where((s) {
      final matchesQuery =
          normalized.isEmpty || s.name.toLowerCase().contains(normalized);
      final matchesCategory = category == null || s.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }
}
