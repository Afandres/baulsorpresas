import 'package:flutter/material.dart';
import 'package:baulsorpresas/models/product.dart';
import 'save_form.dart'; // Importar el nuevo archivo

class SavePage extends StatelessWidget {
  static const String ROUTE = "save";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Guardar"),
      ),
      body: Container(
          child: FormSave(
              product: ModalRoute.of(context)!.settings.arguments as Product?)),
    );
  }
}
