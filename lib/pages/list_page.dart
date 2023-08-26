import 'dart:io';
import 'package:baulsorpresas/pages/sale.dart';
import 'package:baulsorpresas/pages/sale_page.dart';
import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/pages/save_page.dart';
import 'package:baulsorpresas/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';
import 'save_form.dart'; // Importar el nuevo archivo

class ListPage extends StatefulWidget {
  static const String ROUTE = "list";

  final Product? newProduct;
  ListPage({this.newProduct});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Product> productsList = [];

  // Estilo para los Textos normales
  TextStyle commonTextStyle = GoogleFonts.neucha(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );
// Estilo para los títulos negros
  TextStyle titleblackTextStyle = GoogleFonts.neucha(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
// Estilo para los títulos blancos
  TextStyle titleTextStyle = GoogleFonts.neucha(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

// Estilo para los títulos
  TextStyle subtitleTextStyle = GoogleFonts.neucha(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    List<Product> products = await ConexionDB.products();
    setState(() {
      productsList = products;
    });
  }

  // Cerrar session y eliminar el token
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');

    Navigator.pushNamedAndRemoveUntil(
      context,
      Login.ROUTE,
      (Route<dynamic> route) => false,
    );
  }

  //Mostrar el modal de editar
  void _showEditModal(BuildContext context, Product product) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Producto',
            style: titleblackTextStyle,
          ),
          content: FormSave(product: product),
        );
      },
    );
    _loadProducts();
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Venta', style: titleblackTextStyle),
          content: Text(
            '¿Estás seguro que deseas eliminar este producto?',
            style: commonTextStyle,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar',
                  style: commonTextStyle
                      .merge(TextStyle(color: Colors.pinkAccent))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar',
                  style: commonTextStyle
                      .merge(TextStyle(color: Colors.pinkAccent))),
              onPressed: () {
                _deleteProduct(product);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //Mostrar el modal de detalles del producto
  void _showProductDetailsModal(BuildContext context, Product product) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.title, style: subtitleTextStyle),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ignore: unnecessary_null_comparison
              product.images != null
                  ? Image.file(
                      File(product.images),
                      width: 100,
                      height: 100,
                    )
                  : Icon(Icons.image_not_supported),
              SizedBox(height: 20),
              Text(
                'Contenido: ${product.content}',
                style: commonTextStyle,
              ),
              SizedBox(height: 5),
              Text('Precio: ${product.price}', style: commonTextStyle),
              SizedBox(height: 5),
              Text('Cantidad disponible: ${product.quantity}',
                  style: commonTextStyle),
              // Agrega más detalles del producto aquí si es necesario
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar',
                  style: commonTextStyle
                      .merge(TextStyle(color: Colors.pinkAccent))),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar la venta y actualizar la lista
  void _deleteProduct(Product product) async {
    // Si la venta no tiene un ID asignado (es nulo), podemos ignorar la eliminación.
    if (product.id == null) {
      // Aquí puedes manejar el caso especial de una venta sin ID (por ejemplo, mostrar un mensaje de error o simplemente ignorar la eliminación).
      return;
    }

    // Si la venta tiene un ID válido, podemos proceder a eliminarla de la base de datos.
    await ConexionDB.delete(
        product.id!); // Usar el operador ! para acceder al valor no nulo

    // Actualizar la lista de ventas
    _loadProducts();
  }

  void _goToSalesPage() {
    Navigator.pushReplacementNamed(context, VentasPage.ROUTE);
  }

  void _goToViewPage() {
    Navigator.pushNamed(context, SalesPage.ROUTE);
  }

  Future<void> _openSavePage() async {
    var newProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavePage()),
    );

    if (newProduct != null) {
      setState(() {
        productsList.add(newProduct);
      });
    }
  }

  void _updateProductQuantity(Product product, int newQuantity) async {
    // Actualizar la cantidad en la base de datos
    await ConexionDB.updateProductQuantity(product.id!, newQuantity);

    // Buscar el producto en la lista y actualizar su cantidad
    final productIndex =
        productsList.indexWhere((element) => element.id == product.id);
    if (productIndex != -1) {
      setState(() {
        productsList[productIndex].quantity = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aquí obtenemos la etiqueta única cuando se regresa de VentasPage
    var returnData = ModalRoute.of(context)?.settings.arguments;

    // Verificamos si el retorno es de VentasPage y si es así, actualizamos la lista
    if (returnData == 'Venta Cancelada') {
      _loadProducts();
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: Icon(
          Icons.add,
          color: Colors.pinkAccent,
          size: 30,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.pinkAccent, width: 1.0),
          borderRadius: BorderRadius.circular(
              50.0), // Ajusta este valor según tus preferencias
        ),
        onPressed: _openSavePage,
      ),
      appBar: AppBar(
        title: Text('Listado', style: titleTextStyle),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.receipt),
            onPressed: _goToViewPage,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_checkout),
            onPressed: _goToSalesPage,
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: productsList.length,
          itemBuilder: (context, index) {
            final product = productsList[index];
            return ListTile(
              title: Text(productsList[index].title, style: subtitleTextStyle),
              subtitle: Text(
                'Cantidad: ${productsList[index].quantity.toString()}',
                style: commonTextStyle,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _updateProductQuantity(product, product.quantity + 1);
                      });
                    },
                    onLongPress: () async {
                      final updatedQuantity = await showDialog<int>(
                        context: context,
                        builder: (context) {
                          int selectedQuantity = 1; // Valor por defecto
                          return AlertDialog(
                            title: Text('Registrar Cantidad'),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                selectedQuantity =
                                    int.tryParse(value) ?? selectedQuantity;
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, selectedQuantity);
                                },
                                child: Text('Actualizar',
                                    style: commonTextStyle.merge(
                                        TextStyle(color: Colors.pinkAccent))),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancelar',
                                    style: commonTextStyle.merge(
                                        TextStyle(color: Colors.pinkAccent))),
                              ),
                            ],
                          );
                        },
                      );

                      if (updatedQuantity != null) {
                        setState(() {
                          product.quantity += updatedQuantity;
                        });
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility_outlined),
                    onPressed: () {
                      _showProductDetailsModal(context, productsList[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined),
                    onPressed: () {
                      _showEditModal(context, productsList[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outlined),
                    onPressed: () {
                      _showDeleteDialog(context, productsList[index]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    routes: {
      ListPage.ROUTE: (context) => ListPage(),
      SavePage.ROUTE: (context) => SavePage(),
      VentasPage.ROUTE: (context) => VentasPage(),
    },
  ));
}
