import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/models/sale.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  static const String ROUTE = "sales";

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Sale> salesList = [];

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
    _loadSales();
  }

  Future<void> _loadSales() async {
    List<Sale> sales = await ConexionDB.getSales();
    setState(() {
      salesList = sales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Ventas',
          style: titleTextStyle,
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView.builder(
        itemCount: salesList.length,
        itemBuilder: (context, index) {
          Sale sale = salesList[index];
          SizedBox(height: 5);
          return ListTile(
            title: Text(
              'Venta: ${sale.id}',
              style: subtitleTextStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  'Fecha: ${_formatDate(sale.dateTime)}',
                  style: commonTextStyle,
                ),
                SizedBox(height: 5),
                Text(
                  'Total: ${sale.totalAmount.toString()}',
                  style: commonTextStyle,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      _showSaleDetails(sale);
                    },
                    icon: Icon(Icons.visibility_outlined)),
                IconButton(
                    onPressed: () {
                      _showDeleteDialog(sale);
                    },
                    icon: Icon(Icons.delete_outline))
              ],
            ),
          );
        },
      ),
    );
  }

//Text('Total: ${sale.totalAmount.toString()}')
  void _showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detalles de la Venta',
            style: titleblackTextStyle,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID de Venta: ${sale.id}', style: commonminTextStyle),
                Text('Fecha: ${_formatDate(sale.dateTime)}',
                    style: commonminTextStyle),
                Text('Total: ${sale.totalAmount.toString()}',
                    style: commonminTextStyle),
                SizedBox(height: 16),
                Text(
                  'Productos Vendidos:',
                  style: subtitleTextStyle,
                ),
                // Usar un Column en lugar de un ListView.builder
                Column(
                  children: sale.products.map((product) {
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text('Cantidad: ${product.quantity.toString()}',
                          style: commonminTextStyle),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para formatear la fecha
  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm')
        .format(dateTime); // El formato deseado aquí
  }

  void _showDeleteDialog(Sale sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Venta', style: titleblackTextStyle),
          content: Text(
            '¿Estás seguro que deseas eliminar esta venta?',
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
                _deleteSale(sale);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar la venta y actualizar la lista
  void _deleteSale(Sale sale) async {
    // Si la venta no tiene un ID asignado (es nulo), podemos ignorar la eliminación.
    if (sale.id == null) {
      // Aquí puedes manejar el caso especial de una venta sin ID (por ejemplo, mostrar un mensaje de error o simplemente ignorar la eliminación).
      return;
    }

    // Si la venta tiene un ID válido, podemos proceder a eliminarla de la base de datos.
    await ConexionDB.deleteSale(
        sale.id!); // Usar el operador ! para acceder al valor no nulo

    // Actualizar la lista de ventas
    _loadSales();
  }
}
