import 'dart:io';

import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/models/product.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class FormSave extends StatefulWidget {
  final Product? product;
  FormSave({this.product});

  @override
  _FormSaveState createState() => _FormSaveState();
}

class _FormSaveState extends State<FormSave> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final quantityController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      titleController.text = widget.product!.title;
      contentController.text = widget.product!.content;
      priceController.text = widget.product!.price.toString();
      quantityController.text = widget.product!.quantity.toString();
      imageController.text = widget.product!.images;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 15),
                TextFormField(
                  controller: imageController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Tiene que llenar los campos";
                    }
                    // Puedes agregar validaciones adicionales para la imagen si es necesario
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Ruta de la Imagen",
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  child: Text("Seleccionar Imagen"),
                  onPressed: _selectImage,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pinkAccent),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Tiene que llenar los campos";
                    }
                    // Puedes agregar otras validaciones para el precio, por ejemplo, verificar que sea un número válido
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Precio",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Tiene que llenar los campos";
                    }
                    // Puedes agregar otras validaciones para la cantidad, por ejemplo, verificar que sea un número válido
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Cantidad",
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

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Aquí puedes guardar la imagen y obtener la ruta
      String imagePath = await saveImage(File(pickedImage.path));

      // Actualiza el estado con la ruta de la imagen seleccionada
      setState(() {
        // imageController.text = imagePath; // Comentamos esta línea, ya no necesitamos almacenar la ruta en el campo de texto
      });

      // Podemos establecer la ruta de la imagen directamente en el controlador del campo "image" del producto
      imageController.text = imagePath;
    }
  }

  void _saveProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String imagePath =
          imageController.text; // Obtener la ruta de la imagen del controlador

      // Asegurarse de que imagePath no sea nulo y no esté vacío antes de guardar el producto
      // ignore: unnecessary_null_comparison
      if (imagePath != null && imagePath.isNotEmpty) {
        Product updatedProduct = Product(
          id: widget.product?.id,
          title: titleController.text,
          content: contentController.text,
          price: int.parse(priceController.text),
          quantity: int.parse(quantityController.text),
          images:
              imagePath, // Establecer la ruta de la imagen seleccionada en el campo "image" del producto
          quantitySold: widget.product?.quantitySold ??
              0, // Mantener la cantidad vendida si es un producto existente
        );

        if (widget.product != null) {
          // Si es un producto existente, actualizarlo en la base de datos
          await ConexionDB.update(updatedProduct);
        } else {
          // Si es un producto nuevo, insertarlo en la base de datos
          await ConexionDB.insert(updatedProduct);
        }

        Navigator.pop(context, updatedProduct);
      } else {
        // Si la ruta de la imagen es nula o está vacía, mostrar un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Por favor, seleccione una imagen")),
        );
      }
    }
  }
}
