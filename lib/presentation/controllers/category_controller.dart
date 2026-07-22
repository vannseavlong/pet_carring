import 'package:get/get.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'booking_controller.dart' show ViewState;

class CategoryController extends GetxController {
  final GetCategoriesUseCase _getCategories;

  CategoryController(this._getCategories);

  final RxList<Category> categories = <Category>[].obs;
  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoading => state.value == ViewState.loading;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state.value = ViewState.loading;
    try {
      categories.value = await _getCategories();
      state.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
    }
  }

  Category? byId(String categoryId) {
    for (final category in categories) {
      if (category.categoryId == categoryId) return category;
    }
    return null;
  }

  String labelFor(String categoryId) => byId(categoryId)?.name ?? 'Other';
}
