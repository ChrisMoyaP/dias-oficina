import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/pantalla_bienvenida.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pantalla_bienvenida.dart';
import 'screens/pantalla_meses.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  // Solo inicializa para escritorio (Windows/macOS/Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefs = await SharedPreferences.getInstance();
  final nombre = prefs.getString('nombreUsuario');

  runApp(DiasOficinaApp(nombre: nombre));
}

class DiasOficinaApp extends StatelessWidget {
  @override

  final String? nombre;

  DiasOficinaApp({this.nombre});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Días de Oficina',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: nombre != null
          ? PantallaMeses(nombre: nombre!) // ya tiene sesión
          : PantallaBienvenida(),          // nueva sesión
      debugShowCheckedModeBanner: false,
    );
  }
}




