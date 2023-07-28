import 'package:baulsorpresas/pages/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ConexionDB {
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'baulsorpresas.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE products (id INTEGER PRIMARY KEY, title TEXT, content TEXT)");
    }, version: 1);
  }

  static Future<int> insert(Product product) async {
    Database database = await _openDB();
    int id = await database.insert("products", product.toMap());

    // Añadir este bloque para imprimir el registro guardado
    if (id > 0) {
      print("Registro guardado correctamente en la base de datos:");
      print("ID: $id");
      print("Título: ${product.title}");
      print("Contenido: ${product.content}");
    }

    return id;
  }

  static Future<List<Product>> products() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> productsMap =
        await database.query("products");

    // Añadir este bloque para imprimir los registros obtenidos
    print("Registros obtenidos de la base de datos:");
    for (var productMap in productsMap) {
      print("ID: ${productMap['id']}");
      print("Título: ${productMap['title']}");
      print("Contenido: ${productMap['content']}");
    }

    return List.generate(
        productsMap.length,
        (i) => Product(
            id: productsMap[i]['id'],
            title: productsMap[i]['title'],
            content: productsMap[i]['content']));
  }

  static Future<int> update(Product product) async {
    Database database = await _openDB();

    return database.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<int> delete(int productId) async {
    Database database = await _openDB();

    return database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
