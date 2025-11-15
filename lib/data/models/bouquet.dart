import 'package:flutter/material.dart';
import 'package:taba_app/data/models/letter.dart';

class BouquetFolder {
  const BouquetFolder({
    required this.id,
    required this.name,
    required this.color,
    required this.letters,
  });

  final String id;
  final String name;
  final Color color;
  final List<Letter> letters;

  int get count => letters.length;
}
