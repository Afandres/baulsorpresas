import 'dart:convert';
import 'dart:io';

import 'package:baulsorpresas/models/product.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../models/sale.dart';
import '/models/user.dart';

class ConexionDB {
  static Future<Database> openDB() async {
    Database database =
        await openDatabase(join(await getDatabasesPath(), 'baulsorpresas.db'),
            onCreate: (db, version) {
      db.execute(
        "CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, price TEXT, image TEXT, quantity INTEGER)",
      );
      db.execute(
        "CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT, role TEXT, token TEXT)",
      );
      db.execute(
        "CREATE TABLE sales (id INTEGER PRIMARY KEY, username TEXT, totalAmount REAL, dateTime DATETIME)",
      );
      db.execute(
        "CREATE TABLE sales_products (id INTEGER PRIMARY KEY, saleId INTEGER, productId INTEGER, quantity INTEGER)",
      );
      db.execute(
        "CREATE TABLE inventory (productId INTEGER PRIMARY KEY, quantity INTEGER)",
      );
    }, version: 4);

    // Agregar este bloque para crear manualmente la tabla "users" si aún no existe
    await database.execute(
      "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)",
    );
    await database.execute(
      "CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, price TEXT, quantity INTEGER)",
    );

    return database;
  }

  //----------------- Funciones para la Gestion de Productos ------------------------

  // Funcion para Insertar un Producto

  static Future<int> insert(Product product) async {
    Database database = await openDB();

    // Convierte el precio a un objeto double antes de insertarlo en la base de datos
    // ignore: unused_local_variable
    var price = product.price;

    int id = await database.insert("products", {
      "title": product.title,
      "content": product.content,
      "price": product.price, // Aquí se pasa el precio como un objeto double
      "image": product.images,
      "quantity": product.quantity,
    });

    // Añadir este bloque para imprimir el registro guardado
    if (id > 0) {
      print("Registro guardado correctamente en la base de datos:");
      print("ID: $id");
      print("Título: ${product.title}");
      print("Contenido: ${product.content}");
      print("Imagen: ${product.images}");
      print("Precio: ${product.price}");
      print("Cantidad: ${product.quantity}");
    }

    return id;
  }

  // Funcion para Listar los Productos

  static Future<List<Product>> products() async {
    Database database = await openDB();
    final List<Map<String, dynamic>> productsMap =
        await database.query("products");

    // Añadir este bloque para imprimir los registros obtenidos
    print("Registros obtenidos de la base de datos:");
    for (var productMap in productsMap) {
      print("ID: ${productMap['id']}");
      print("Título: ${productMap['title']}");
      print("Contenido: ${productMap['content']}");
      print("image: ${productMap['image']}");
    }

    return List.generate(
        productsMap.length,
        (i) => Product(
            id: productsMap[i]['id'],
            title: productsMap[i]['title'],
            images: productsMap[i]['image'] ?? "",
            price: int.parse(productsMap[i]['price']),
            quantity: productsMap[i]['quantity'],
            content: productsMap[i]['content']));
  }

  // Funcion para Modificar un Producto

  static Future<int> update(Product product) async {
    Database database = await openDB();

    return database.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Funcion para Eliminar un Producto

  static Future<int> delete(int productId) async {
    Database database = await openDB();

    return database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Funcion para Obtener Producto por ID

  static Future<Product?> getProductById(int productId) async {
    Database database = await openDB();
    final List<Map<String, dynamic>> productsMap = await database.query(
      "products",
      where: "id = ?",
      whereArgs: [productId],
    );

    if (productsMap.isEmpty) {
      // Si no se encontró ningún producto con el ID dado, devolver null
      return null;
    }

    return Product(
      id: productsMap.first['id'],
      title: productsMap.first['title'],
      price: int.parse(productsMap.first['price']),
      content: productsMap.first['content'],
      quantity: productsMap.first['quantity'],
      images: productsMap.first['image'],
    );
  }

  //Funcion para listar los producto y enviarlos por medio de una API
  static Future<List<Product>> getProductsFromApi() async {
    final response = await http.get(Uri.parse('TU_URL_AQUI'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Product> products = [];

      for (var productData in data) {
        products.add(Product(
          id: productData['id'],
          title: productData['title'],
          images: productData['image'] ?? "",
          price: int.parse(productData['price']),
          quantity: productData['quantity'],
          content: productData['content'],
        ));
      }

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  

  //----------------- Funciones para la Gestion de Usuario ------------------------

  // Funcion para Registrar un Usuario

  static Future<int> insertUser(User user) async {
    Database database = await openDB();

    // Generar un token único para el usuario
    String token = Uuid().v4();
    user.token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_token', user.token);

    int id = await database.insert("users", user.toMap());
    return id;
  }

  static Future<String> getUserRole(String username) async {
    Database database = await openDB();

    final List<Map<String, dynamic>> usersMap = await database.query(
      "users",
      columns: [
        "role"
      ], // Asegúrate de tener una columna "role" en tu tabla de usuarios
      where: "username = ?",
      whereArgs: [username],
    );

    if (usersMap.isEmpty) {
      // Devolver un valor por defecto si no se encontró el usuario
      return 'user'; // o cualquier otro valor por defecto que desees
    }

    String role = usersMap.first['role'];
    return role;
  }

  // Funcion para Obtener un Usuario por el Nombre

  static Future<User?> getUserByUsername(String username) async {
    Database database = await openDB();
    final List<Map<String, dynamic>> usersMap = await database
        .query("users", where: "username = ?", whereArgs: [username]);

    if (usersMap.isEmpty) {
      // Devolver null si no se encontró ningún usuario
      return null;
    }

    return User.fromMap(usersMap.first);
  }

  // Funcion para Obtener el Token

  static Future<String?> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token') ??
        ''; // Retorna una cadena vacía si no hay un token válido
  }

  //----------------Funciones para la Gestion y Relacion entre Productos y Ventas  ---------------------

  static Future<int> insertSale(Sale sale) async {
    Database database = await openDB();
    int saleId = await database.insert("sales", sale.toMap());

    // Relacionar los productos con la venta en la tabla intermedia
    for (var product in sale.products) {
      await database.insert("sales_products", {
        "saleId": saleId,
        "productId": product.id,
        "quantity": product.quantity,
      });
    }

    return saleId;
  }

  // Funcion para listar las ventas
  static Future<List<Sale>> getSales() async {
    Database database = await openDB();
    final List<Map<String, dynamic>> salesMap = await database.query("sales");

    List<Sale> sales = [];
    for (var saleMap in salesMap) {
      List<Map<String, dynamic>> saleProductsMap = await database.query(
          "sales_products",
          where: "saleId = ?",
          whereArgs: [saleMap["id"]]);

      List<Product> products = [];
      for (var saleProductMap in saleProductsMap) {
        Product? product = await getProductById(saleProductMap["productId"]);
        // ignore: unnecessary_null_comparison
        if (product != null) {
          product.quantity = saleProductMap["quantity"];
          products.add(product);
        }
      }

      Sale sale = Sale(
        id: saleMap["id"],
        dateTime: DateTime.parse(saleMap["dateTime"]),
        totalAmount: saleMap["totalAmount"],
        products: products,
      );

      sales.add(sale);
    }

    return sales;
  }

  static Future<void> deleteSale(int saleId) async {
    Database database = await openDB();

    // Eliminar la venta de la tabla "sales" por su ID
    await database.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [saleId],
    );

    // Eliminar los registros relacionados de la tabla intermedia "sales_products"
    await database.delete(
      'sales_products',
      where: 'saleId = ?',
      whereArgs: [saleId],
    );
  }

  // Función para obtener la cantidad disponible de un producto en el inventario
  static Future<int> getQuantityInInventory(int productId) async {
    Database database = await openDB();
    final List<Map<String, dynamic>> inventoryMap = await database.query(
      "products", // Nombre de la tabla de productos
      columns: ["quantity"], // Solo necesitamos la columna de cantidad
      where: "id = ?", // Filtrar por el ID del producto
      whereArgs: [productId], // Valor del ID del producto
    );

    if (inventoryMap.isEmpty) {
      // Si no se encontró el producto en el inventario, devolver 0
      return 0;
    }

    int quantity = inventoryMap.first['quantity'];
    print('Cantidad en inventario del producto $productId: $quantity');
    return quantity;
  }

  static Future<void> updateProductQuantity(
      int productId, int newQuantity) async {
    Database database = await openDB();

    await database.update(
      'products', // Nombre de la tabla de productos
      {'quantity': newQuantity}, // Datos a actualizar (solo la cantidad)
      where: 'id = ?', // Filtrar por el ID del producto
      whereArgs: [productId], // Valor del ID del producto
    );
  }
}
// -------------------- Funciones para la Gestion de Imagenes del Producto---------------------

Future<String> saveImage(File imageFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final imagePath = "${directory.path}/$fileName.jpg";

  await imageFile.copy(imagePath);
  return imagePath;
}
