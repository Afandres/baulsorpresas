import 'package:baulsorpresas/pages/list_page.dart';
import 'package:baulsorpresas/pages/registro.dart';
import 'package:baulsorpresas/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:baulsorpresas/db/conexion.dart';
import 'package:baulsorpresas/models/user.dart';

class Login extends StatefulWidget {
  static const String ROUTE = "/login";

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginUser() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      User? authenticatedUser = await ConexionDB.getUserByUsername(username);
      String userRole = await ConexionDB.getUserRole(username);

      if (authenticatedUser != null && authenticatedUser.password == password) {
        // Autenticación exitosa
        _showAlertDialog(
            "Autenticación Exitosa", "¡Usuario autenticado correctamente!");
        _usernameController.clear();
        _passwordController.clear();

        if (userRole == 'admin') {
          Navigator.pushReplacementNamed(context, ListPage.ROUTE);
        } else {
          Navigator.pushReplacementNamed(context, UserView.ROUTE);
        }
      } else {
        // Error en la autenticación
        _showAlertDialog(
            "Error", "Credenciales inválidas. Inténtalo de nuevo.");
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
                        MaterialStateProperty.all(Colors.pinkAccent))),
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
        title: Text('Login de Usuario'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('assets/images/logo.png')),
              ),
            ),
            SizedBox(
              height: 40,
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
                  hintText: 'Ingrese su nombre de usuario',
                  prefixIcon: Icon(Icons.person_2_outlined),
                ),
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
                  hintText: 'Ingrese su contraseña',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, Registro.ROUTE);
              },
              child: Text(
                'Crear Cuenta',
                style: TextStyle(color: Colors.pinkAccent, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              width: 190,
              decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                onPressed: () {
                  _loginUser();
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
