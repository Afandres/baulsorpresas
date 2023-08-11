class Product {
  final int? id;
  final String title;
  final String content;
  late int price;
  String images;
  int quantity;
  int quantitySold; // Nueva propiedad para la cantidad vendida

  Product({
    this.id,
    this.title = '',
    this.content = '',
    this.price = 0,
    this.images = '',
    this.quantity = 0,
    this.quantitySold = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'price': price,
      'image': images,
      'quantity': quantity,
    };
  }
}
