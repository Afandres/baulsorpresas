import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/models/sale.dart';

import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  static const String ROUTE = "sales";

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Sale> salesList = [];

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
        title: Text('Lista de Ventas'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView.builder(
        itemCount: salesList.length,
        itemBuilder: (context, index) {
          Sale sale = salesList[index];
          SizedBox(height: 5);
          return ListTile(
            title: Text('Venta: ${sale.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text('Fecha: ${_formatDate(sale.dateTime)}'),
                SizedBox(height: 5),
                Text('Total: ${sale.totalAmount.toString()}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      _showSaleDetails(sale);
                    },
                    icon: Icon(Icons.visibility)),
                IconButton(
                    onPressed: () {
                      _showDeleteDialog(sale);
                    },
                    icon: Icon(Icons.delete))
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
          title: Text('Detalles de la Venta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID de Venta: ${sale.id}'),
                Text('Fecha: ${_formatDate(sale.dateTime)}'),
                Text('Total: ${sale.totalAmount.toString()}'),
                SizedBox(height: 16),
                Text('Productos Vendidos:'),
                // Usar un Column en lugar de un ListView.builder
                Column(
                  children: sale.products.map((product) {
                    return ListTile(
                      title: Text(product.title),
                      subtitle:
                          Text('Cantidad: ${product.quantity.toString()}'),
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
          title: Text('Eliminar Venta'),
          content: Text('¿Estás seguro que deseas eliminar esta venta?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
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
