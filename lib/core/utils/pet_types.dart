class PetTypeOption {
  final String value;
  final String label;
  final String emoji;
  const PetTypeOption(this.value, this.label, this.emoji);
}

abstract final class PetTypes {
  static const all = [
    PetTypeOption('dog', 'Dog', '🐶'),
    PetTypeOption('cat', 'Cat', '🐱'),
    PetTypeOption('bird', 'Bird', '🐦'),
    PetTypeOption('rabbit', 'Rabbit', '🐰'),
    PetTypeOption('other', 'Other', '🐾'),
  ];

  static String emojiFor(String value) => all
      .firstWhere(
        (t) => t.value == value.toLowerCase(),
        orElse: () => all.last,
      )
      .emoji;
}
