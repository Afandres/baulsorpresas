import 'package:baulsorpresas/models/product.dart';

class Sale {
  late int? id;
  final DateTime dateTime;
  final double totalAmount;
  final List<Product> products; // Agregar este campo

  Sale(
      { this.id,
      required this.dateTime,
      required this.totalAmount,
      required this.products});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }
}
