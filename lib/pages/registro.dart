import 'package:baulsorpresas/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:baulsorpresas/models/user.dart';
import 'package:baulsorpresas/db/conexion.dart';



class Registro extends StatefulWidget {
  static const String ROUTE = "/register";
  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _registerUser() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      // Verificar si ya existe un usuario con el mismo username
      User? existingUser = await ConexionDB.getUserByUsername(username);

      if (existingUser == null) {
        // Si no existe un usuario con el mismo username, procede con el registro
        User user = User(
            username: username,
            password: password,
            role: 'user'); // Asignar el rol 'user'
        int userId = await ConexionDB.insertUser(user);
        if (userId > 0) {
          // Registro exitoso
          _showAlertDialog(
              "Registro Exitoso", "Usuario registrado correctamente.");
          _usernameController.clear();
          _passwordController.clear();
          Navigator.pushReplacementNamed(context, UserView.ROUTE);
        } else {
          // Error en el registro
          _showAlertDialog("Error", "No se pudo registrar el usuario.");
        }
      } else {
        // Si ya existe un usuario con el mismo username, muestra un mensaje de error
        _showAlertDialog("Error",
            "El username ya está en uso. Inténtalo de nuevo con otro.");
      }
    } else {
      _showAlertDialog("Error", "Ingresa el usuario y la contraseña.");
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.pinkAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Registro de Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 160),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pinkAccent),
                      ),
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Ingrese su nombre de usuario'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pinkAccent),
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Ingrese su contraseña'),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                height: 50,
                width: 190,
                decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(10)),
                child: TextButton(
                  onPressed: () {
                    _registerUser();
                  },
                  child: Text(
                    'Registrar',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
