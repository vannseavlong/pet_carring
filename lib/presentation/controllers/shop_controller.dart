import 'package:get/get.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/shop.dart';
import '../../domain/usecases/get_catalog_items_usecase.dart';
import '../../domain/usecases/get_shops_usecase.dart';
import 'booking_controller.dart' show ViewState;

class ShopController extends GetxController {
  final GetShopsUseCase _getShops;
  final GetCatalogItemsUseCase _getCatalogItems;

  ShopController(this._getShops, this._getCatalogItems);

  final RxList<Shop> shops = <Shop>[].obs;
  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString errorMessage = ''.obs;

  final RxList<CatalogItem> selectedShopCatalog = <CatalogItem>[].obs;
  final Rx<ViewState> catalogState = ViewState.idle.obs;

  bool get isLoading => state.value == ViewState.loading;
  bool get isLoadingCatalog => catalogState.value == ViewState.loading;

  @override
  void onInit() {
    super.onInit();
    fetchShops();
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
