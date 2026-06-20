import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

abstract final class ServiceIcons {
  static const Map<String, IconData> _byKey = {
    'bath': HugeIcons.strokeRoundedShampoo,
    'shampoo': HugeIcons.strokeRoundedShampoo,
    'grooming': HugeIcons.strokeRoundedShampoo,
    'walk': HugeIcons.strokeRoundedBone01,
    'walking': HugeIcons.strokeRoundedBone01,
    'bone': HugeIcons.strokeRoundedBone01,
    'play': HugeIcons.strokeRoundedTennisBall,
    'tennis_ball': HugeIcons.strokeRoundedTennisBall,
    'medicine': HugeIcons.strokeRoundedMedicine01,
    'meds': HugeIcons.strokeRoundedMedicine01,
    'care': HugeIcons.strokeRoundedMedicine01,
    'scissors': HugeIcons.strokeRoundedScissor,
    'scissor': HugeIcons.strokeRoundedScissor,
    'haircut': HugeIcons.strokeRoundedScissor,
    'car': HugeIcons.strokeRoundedCar01,
    'transport': HugeIcons.strokeRoundedCar01,
    'pickup': HugeIcons.strokeRoundedCar01,
  };

  /// Falls back to a generic paw icon for unrecognized keys, since the
  /// backend's icon key vocabulary isn't pinned down anywhere we can read.
  static IconData resolve(String key) => _byKey[key.toLowerCase()] ?? Icons.pets;
}
