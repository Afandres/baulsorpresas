import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/pages/models/product.dart';

class FormSave extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final Product? product; // Producto existente para la edición

  FormSave({this.product});

  @override
  Widget build(BuildContext context) {
    if (product != null) {
      titleController.text = product!.title;
      contentController.text = product!.content;
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Tiene que llenar los campos";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Titulo",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: contentController,
                  maxLines: 8,
                  maxLength: 1000,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Tiene que llenar los campos";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Contenido",
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  child: Text("Guardar"),
                  onPressed: () => _saveProduct(context),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pinkAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Product updatedProduct = Product(
        id: product?.id, // Si es edición, asignar el id existente
        title: titleController.text,
        content: contentController.text,
      );

      if (product != null) {
        // Si es edición, actualizar el producto en la base de datos
        await ConexionDB.update(updatedProduct);
      } else {
        // Si es creación, insertar el nuevo producto en la base de datos
        await ConexionDB.insert(updatedProduct);
      }

      Navigator.pop(
          context); // Volver a la página anterior después de guardar o editar el producto
    }
  }
  
}
