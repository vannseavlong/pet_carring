import 'package:get/get.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/get_services_usecase.dart';
import 'booking_controller.dart' show ViewState;

class ServiceController extends GetxController {
  final GetServicesUseCase _getServices;

  ServiceController(this._getServices);

  final RxList<Service> services = <Service>[].obs;
  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoading => state.value == ViewState.loading;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    state.value = ViewState.loading;
    try {
      services.value = await _getServices();
      state.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
    }
  }
}
