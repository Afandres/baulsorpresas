import 'package:flutter/material.dart';
import 'dart:io';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/models/product.dart';
import 'package:baulsorpresas/models/sale.dart';
import 'package:google_fonts/google_fonts.dart';

import 'list_page.dart';

class VentasPage extends StatefulWidget {
  static const String ROUTE = "ventas";
  // ignore: unused_field

  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  List<Product> _selectedProducts = [];
  List<Product> _tempSelectedProducts = [];

  // Estilo para los Textos normales
  TextStyle commonTextStyle = GoogleFonts.neucha(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );
// Estilo para los Textos normales
  TextStyle commonminTextStyle = GoogleFonts.neucha(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

// Estilo para los títulos blancos
  TextStyle titleTextStyle = GoogleFonts.neucha(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

// Estilo para los títulos
  TextStyle subtitleblackTextStyle = GoogleFonts.neucha(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

// Estilo para los títulos
  TextStyle subtitleTextStyle = GoogleFonts.neucha(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  // ignore: unused_field
  double _totalAmount = 0;
  // ignore: unused_field
  List<Product> _originalProducts = [];
  List<Product> _originalInventoryProducts =
      []; // Variable para almacenar las cantidades originales

  Future<void> _loadOriginalInventoryProducts() async {
    // Obtiene todos los productos del inventario con sus cantidades originales
    _originalInventoryProducts = await ConexionDB.products();
  }

  @override
  void initState() {
    super.initState();
    _loadOriginalInventoryProducts(); // Cargar las cantidades originales al iniciar la vista
  }

  // Método para cancelar una venta y restaurar las cantidades originales en el inventario
  void _cancelSale() async {
    // Restaurar las cantidades originales en el inventario
    for (var product in _selectedProducts) {
      // Obtener la cantidad original del producto antes de la venta
      Product originalInventoryProduct = _originalInventoryProducts.firstWhere(
        (p) => p.id == product.id,
        orElse: () => Product(
          id: product.id,
          title: '',
          content: '',
          price: 0,
          images: '',
          quantity: 0,
        ),
      );

      // Actualizar la cantidad del producto en el inventario
      await ConexionDB.updateProductQuantity(
        product.id!,
        originalInventoryProduct.quantity,
      );
    }

    // Verificar si el widget está montado antes de llamar a setState()
    if (mounted) {
      // Limpiar los productos seleccionados y restablecer las variables de estado
      setState(() {
        _selectedProducts.clear();
        _tempSelectedProducts.clear();
      });
    }
  }

  // Método para mostrar la lista de productos disponibles
  Widget _buildProductList() {
    return FutureBuilder<List<Product>>(
      future: ConexionDB.products(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error al cargar los productos');
          }

          List<Product> products = snapshot.data ?? [];
          _originalProducts =
              List.from(products); // Copia temporal de los productos originales
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              return ListTile(
                leading: Image.file(
                  // Utiliza Image.file() para cargar la imagen desde el archivo local
                  File(product
                      .images), // Ruta de la imagen del producto (archivo local)
                  width:
                      50, // Ajusta el tamaño de la imagen según sea necesario
                  height: 50,
                ),
                title: Text(
                  product.title,
                  style: subtitleblackTextStyle,
                ),
                subtitle: Text(
                  'Cantidad disponible: ${product.quantity}',
                  style: commonminTextStyle,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _addSelectedProduct(product);
                  },
                ),
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<double> getTotalAmount() async {
    double totalAmount = 0;
    for (var product in _selectedProducts) {
      int currentQuantity =
          await ConexionDB.getQuantityInInventory(product.id!);
      if (currentQuantity > 0) {
        totalAmount += product.price;
      }
    }
    return totalAmount;
  }

  // Método para agregar un producto a la lista de selección
  // Método para agregar un producto a la lista de selección
  void _addSelectedProduct(Product product) async {
    int currentQuantity = await ConexionDB.getQuantityInInventory(product.id!);

    if (currentQuantity > 0) {
      setState(() {
        // Restar 1 a la cantidad disponible en el inventario
        ConexionDB.updateProductQuantity(product.id!, currentQuantity - 1);

        // Buscar el producto en la lista de productos disponibles
        Product availableProduct = _selectedProducts.firstWhere(
          (p) => p.id == product.id,
          orElse: () => Product(
            id: product.id,
            title: '',
            content: '',
            price: 0,
            images: '',
            quantity: 0,
          ),
        );

        if (availableProduct.quantity > 0) {
          // Si el producto ya está en la lista de seleccionados, incrementar la cantidad
          availableProduct.quantity++;

          // Actualizar la cantidad disponible en la lista temporal de productos (antes de la venta)
          Product tempProduct = _tempSelectedProducts.firstWhere(
            (p) => p.id == product.id,
            orElse: () => Product(
              id: product.id,
              title: '',
              content: '',
              price: 0,
              images: '',
              quantity: 0,
            ),
          );
          tempProduct.quantity--;
        } else {
          // Si el producto no está en la lista de seleccionados, agregarlo
          _selectedProducts.add(Product(
            id: product.id,
            title: product.title,
            content: product.content,
            price: product.price,
            images: product.images,
            quantity: 1, // Empezamos con una cantidad de 1
          ));

          // Actualizar la cantidad disponible en la lista temporal de productos (antes de la venta)
          Product tempProduct = _tempSelectedProducts.firstWhere(
            (p) => p.id == product.id,
            orElse: () => Product(
              id: product.id,
              title: '',
              content: '',
              price: 0,
              images: '',
              quantity: 0,
            ),
          );
          tempProduct.quantity--;
        }

        // Actualizar el precio total de la venta
        _totalAmount += product.price;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pinkAccent,
          content: Text(
            'No hay más unidades disponibles de ${product.title}',
            style: commonminTextStyle.merge(TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
  }

// Método para mostrar la lista de productos seleccionados en la venta
  Widget _buildSelectedProductsList() {
    return ListView.builder(
      itemCount: _selectedProducts.length,
      itemBuilder: (context, index) {
        Product product = _selectedProducts[index];
        return ListTile(
          title: Text(
            product.title,
            style: commonTextStyle,
          ),
          subtitle: Text(
            product.content,
            style: commonminTextStyle,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () async {
                  int currentQuantity =
                      await ConexionDB.getQuantityInInventory(product.id!);
                  setState(() {
                    if (_selectedProducts[index].quantity > 0) {
                      _selectedProducts[index]
                          .quantity--; // Decrementar la cantidad seleccionada
                      // Incrementar la cantidad disponible en el inventario
                      ConexionDB.updateProductQuantity(
                          product.id!, currentQuantity + 1);
                    }
                    // Si la cantidad seleccionada llega a cero, quitar el producto de la lista
                    if (_selectedProducts[index].quantity == 0) {
                      _selectedProducts.removeAt(index);
                    }
                  });
                },
              ),
              Text(
                'Cantidad: ${product.quantity}',
                style: commonminTextStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeSelectedProduct(Product product) async {
    int currentQuantity = await ConexionDB.getQuantityInInventory(product.id!);
    setState(() {
      if (product.quantity > 0) {
        product.quantity--; // Decrementar la cantidad seleccionada
        // Incrementar la cantidad disponible en el inventario
        ConexionDB.updateProductQuantity(product.id!, currentQuantity + 1);

        // Actualizar el precio total de la venta
        _totalAmount -= product.price;

        // Si la cantidad seleccionada llega a cero, quitar el producto de la lista
        if (product.quantity == 0) {
          _selectedProducts.remove(product);
        }
      }
    });
  }

  // Registrar la venta y actualizar el inventario
  Future<void> _registerSaleAndUpdateInventory() async {
    DateTime currentDateTime = DateTime.now();
    double totalAmount = 0;

    // Creamos una copia de la lista de productos seleccionados para no afectar la original
    List<Product> selectedProductsCopy = List.from(_selectedProducts);

    for (var product in _selectedProducts) {
      // Obtener el producto por su ID
      Product? dbProduct = await ConexionDB.getProductById(product.id!);

      if (dbProduct != null) {
        int currentQuantity =
            await ConexionDB.getQuantityInInventory(dbProduct.id!);
        if (currentQuantity > 0) {
          // Restar 1 a la cantidad disponible en el inventario
          await ConexionDB.updateProductQuantity(
              dbProduct.id!, currentQuantity - 1);

          // Calcular el precio total del producto teniendo en cuenta la cantidad seleccionada
          totalAmount += product.price * product.quantity;
        } else {
          // Si no hay suficientes unidades disponibles, eliminar el producto de la lista
          selectedProductsCopy.remove(product);
        }
      }
    }

    Sale sale = Sale(
      dateTime: currentDateTime,
      totalAmount: totalAmount,
      products: selectedProductsCopy,
    );

    // Llamar a la función insertSale para registrar la venta
    await ConexionDB.insertSale(sale);

    // Limpiamos los productos seleccionados, ya que la venta se ha registrado
    _selectedProducts.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text(
          'Venta registrada correctamente',
          style: commonminTextStyle.merge(TextStyle(color: Colors.white)),
        ),
      ),
    );
    Navigator.pushReplacementNamed(context, ListPage.ROUTE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        title: Text(
          'Ventas',
          style: titleTextStyle,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildProductList(),
          ),
          Divider(),
          Expanded(
            child: _buildSelectedProductsList(),
          ),
          ElevatedButton(
            onPressed: () {
              _registerSaleAndUpdateInventory();
            },
            child: Text('Registrar Venta', style: subtitleTextStyle),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.pinkAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _cancelSale();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.pinkAccent,
                  content: Text('Venta cancelada',
                      style: commonminTextStyle
                          .merge(TextStyle(color: Colors.white))),
                ),
              );
              Navigator.pushReplacementNamed(context, ListPage.ROUTE);
            },
            child: Text('Cancelar Venta', style: subtitleTextStyle),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.pinkAccent),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: VentasPage(),
  ));
}
