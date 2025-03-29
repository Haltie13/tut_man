class Student {
  final int? id;
  final String name;
  final double pricePerHour;

  Student({
    this.id,
    required this.name,
    required this.pricePerHour,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'pricePerHour': pricePerHour,
    };
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      pricePerHour: map['pricePerHour'] as double,
    );
  }
}