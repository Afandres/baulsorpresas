import 'package:baulsorpresas/pages/registro.dart';
import 'package:baulsorpresas/pages/sale.dart';
import 'package:baulsorpresas/pages/sale_page.dart';
import 'package:flutter/material.dart';
import 'package:baulsorpresas/pages/list_page.dart';
import 'package:baulsorpresas/pages/save_page.dart';
import 'package:baulsorpresas/pages/user_page.dart';
import 'package:baulsorpresas/pages/login.dart'; // Importa la página de login
import 'package:baulsorpresas/db/conexion.dart';
import 'package:sqflite/sqflite.dart';

import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getDatabasePath();
  _insertAdminUserIfNotExists();
  runApp(MyApp());
}

Future<void> getDatabasePath() async {
  // Obtener el directorio de la aplicación para bases de datos
  final databasesPath = await getDatabasesPath();
  final String dbPath = "$databasesPath/baulsorpresas.db";

  print("Ruta de la base de datos: $dbPath");
}

void _insertAdminUserIfNotExists() async {
  String adminUsername = 'admin'; // Cambia esto al nombre de usuario que desees
  String adminPassword = 'admin123'; // Cambia esto a la contraseña que desees
  String adminRole = 'admin'; // Rol de administrador

  User? existingAdmin = await ConexionDB.getUserByUsername(adminUsername);

  if (existingAdmin == null) {
    User adminUser = User(
      username: adminUsername,
      password: adminPassword,
      role: adminRole,
    );

    await ConexionDB.insertUser(adminUser);
    print('Usuario administrador insertado.');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ConexionDB.getUserToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String? userToken = snapshot.data;

          // Comprobar si el usuario tiene un token válido
          bool isLoggedIn = userToken != null && userToken.isNotEmpty;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: isLoggedIn ? ListPage() : Login(),
            routes: {
              ListPage.ROUTE: (_) => ListPage(),
              SavePage.ROUTE: (_) => SavePage(),
              Login.ROUTE: (_) => Login(),
              Registro.ROUTE: (_) => Registro(),
              VentasPage.ROUTE: (_) => VentasPage(),
              SalesPage.ROUTE: (context) => SalesPage(),
              UserView.ROUTE: (context) => UserView(),
            },
          );
        } else {
          // Mientras se obtiene el token, muestra un cargador, por ejemplo
          return CircularProgressIndicator();
        }
      },
    );
  }
}
