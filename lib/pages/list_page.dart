import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/pages/save_page.dart';
import 'package:baulsorpresas/pages/models/product.dart';
import 'save_form.dart'; // Importar el nuevo archivo

class ListPage extends StatefulWidget {
  static const String ROUTE = "/";

  // Agregar el constructor que acepta newProduct
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, SavePage.ROUTE);
        },
      ),
      appBar: AppBar(
        title: Text('Listado'),
        backgroundColor: Colors.pinkAccent,
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

  // Función para mostrar el modal de edición
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

  // Función para eliminar un producto
  void _deleteProduct(BuildContext context, int? productId) async {
    if (productId != null) {
      await ConexionDB.delete(productId);
      _loadProducts(); // Recargar la lista después de la eliminación
    } else {
      // Manejar la situación cuando productId es nulo
      // Por ejemplo, mostrar un mensaje de error o realizar alguna otra acción
    }
  }
}
