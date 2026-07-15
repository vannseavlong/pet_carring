class ShopCategoryOption {
  final String value;
  final String label;
  final String emoji;
  const ShopCategoryOption(this.value, this.label, this.emoji);
}

abstract final class ShopCategories {
  static const all = [
    ShopCategoryOption('grooming', 'Grooming', '🛁'),
    ShopCategoryOption('boarding', 'Boarding', '🏡'),
    ShopCategoryOption('daycare', 'Daycare', '🎾'),
    ShopCategoryOption('pet_shop', 'Pet Shop', '🛍️'),
  ];

  static String labelFor(String value) => all
      .firstWhere(
        (c) => c.value == value.toLowerCase(),
        orElse: () => const ShopCategoryOption('', 'Other', '🐾'),
      )
      .label;
}
