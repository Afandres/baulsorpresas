import 'dart:io';

import 'package:flutter/material.dart';
import 'package:baulsorpresas/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baulsorpresas/pages/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:baulsorpresas/db/conexion.dart'; // Asegúrate de importar el archivo de conexión

class UserView extends StatefulWidget {
  static const String ROUTE = "user";

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  List<Product> availableProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _openWhatsApp() async {
    String phoneNumber = '+573116698590';
    String message = '¡Hola! Estoy interesado en tus productos.';

    final whatsappUrl =
        'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        throw 'No se pudo abrir WhatsApp.';
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
    }
  }

  Future<void> _loadProducts() async {
    List<Product> products =
        await ConexionDB.products(); // Cargar productos disponibles
    setState(() {
      availableProducts = products;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');

    Navigator.pushNamedAndRemoveUntil(
      context,
      Login.ROUTE,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: Image.asset(
          './assets/images/whatsapp.png', // Ruta de la imagen en tu proyecto
          width: 24, // Ajusta el tamaño según sea necesario
          height: 24,
          color: Colors.white,
        ),
        onPressed: _openWhatsApp,
      ),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Productos Disponibles'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: availableProducts.length,
        itemBuilder: (ctx, index) {
          final product = availableProducts[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Image.file(
                // Utiliza Image.file() para cargar la imagen desde el archivo local
                File(product
                    .images), // Ruta de la imagen del producto (archivo local)
                width: 50, // Ajusta el tamaño de la imagen según sea necesario
                height: 50,
              ),
              title: Text(product.title),
              subtitle: Text('Precio: \$${product.price}'),
              trailing: Text('Cantidad: ${product.quantity}'),
            ),
          );
        },
      ),
    );
  }
}
