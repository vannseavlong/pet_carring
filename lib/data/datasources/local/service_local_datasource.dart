import '../../models/service_model.dart';

abstract interface class ServiceLocalDataSource {
  Future<List<ServiceModel>> getCachedServices();
  Future<void> cacheServices(List<ServiceModel> services);
}

class ServiceLocalDataSourceImpl implements ServiceLocalDataSource {
  // Seeded with dev mock data; cleared and replaced once API responds.
  final List<ServiceModel> _cache = [
    const ServiceModel(
      serviceId: 'svc_bath_grm',
      name: 'Bath & Grooming',
      description: 'A full wash, blow-dry and brush-out.',
      priceFrom: 25,
      icon: 'bath',
      color: '#E8F0EE',
      category: 'grooming',
    ),
    const ServiceModel(
      serviceId: 'svc_walk',
      name: 'Dog Walking',
      description: 'A loop around the neighborhood.',
      priceFrom: 15,
      icon: 'walk',
      color: '#F5EDE6',
      category: 'exercise',
    ),
    const ServiceModel(
      serviceId: 'svc_play',
      name: 'Playtime',
      description: 'Supervised play and enrichment.',
      priceFrom: 12,
      icon: 'play',
      color: '#E8F0EE',
      category: 'exercise',
    ),
    const ServiceModel(
      serviceId: 'svc_meds',
      name: 'Meds & Care',
      description: 'Administering prescribed medication.',
      priceFrom: 10,
      icon: 'medicine',
      color: '#EDE8F5',
      category: 'care',
    ),
    const ServiceModel(
      serviceId: 'svc_haircut',
      name: 'Haircut & Styling',
      description: 'Breed-standard or custom trim.',
      priceFrom: 30,
      icon: 'scissors',
      color: '#F5EDE6',
      category: 'grooming',
    ),
    const ServiceModel(
      serviceId: 'svc_transport',
      name: 'Pick-up & Drop-off',
      description: 'Door-to-door transport for your pet.',
      priceFrom: 20,
      icon: 'car',
      color: '#E8F0EE',
      category: 'transport',
    ),
  ];

  @override
  Future<List<ServiceModel>> getCachedServices() async =>
      List.unmodifiable(_cache);

  @override
  Future<void> cacheServices(List<ServiceModel> services) async {
    _cache
      ..clear()
      ..addAll(services);
  }
}
