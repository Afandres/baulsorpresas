class Product {
  final int? id;
  final String title;
  final String content;

  Product({this.id, this.title = '', this.content = ''});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }
}
