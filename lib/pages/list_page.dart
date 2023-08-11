import 'dart:io';
import 'package:baulsorpresas/pages/sale.dart';
import 'package:baulsorpresas/pages/sale_page.dart';
import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/pages/save_page.dart';
import 'package:baulsorpresas/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          title: Text('Editar Producto'),
          content: FormSave(product: product),
        );
      },
    );
    _loadProducts();
  }

  //Mostrar el modal de detalles del producto
  void _showProductDetailsModal(BuildContext context, Product product) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.title),
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
              Text('Contenido: ${product.content}'),
              SizedBox(height: 5),
              Text('Precio: ${product.price}'),
              SizedBox(height: 5),
              Text('Cantidad disponible: ${product.quantity}'),
              // Agrega más detalles del producto aquí si es necesario
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar', selectionColor: Colors.pinkAccent),
            ),
          ],
        );
      },
    );
  }

  //Eliminar el producto
  void _deleteProduct(BuildContext context, int? productId) async {
    if (productId != null) {
      await ConexionDB.delete(productId);
      _loadProducts();
    } else {
      // Handle the situation when productId is null
    }
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
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.add),
        onPressed: _openSavePage,
      ),
      appBar: AppBar(
        title: Text('Listado'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.window),
            onPressed: _goToViewPage,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _goToSalesPage,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: productsList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(productsList[index].title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: () {
                      _showProductDetailsModal(context, productsList[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditModal(context, productsList[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteProduct(context, productsList[index].id);
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
