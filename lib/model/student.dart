import 'package:decimal/decimal.dart';

class Student {
  final int? id;
  final String name;
  final Decimal pricePerHour;

  Student({
    this.id,
    required this.name,
    required this.pricePerHour,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'pricePerHour': pricePerHour.toString(),
    };
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      pricePerHour: Decimal.parse(map['pricePerHour'] as String),
    );
  }
}
