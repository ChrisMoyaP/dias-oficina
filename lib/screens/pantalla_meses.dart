import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'pantalla_generador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/pantalla_bienvenida.dart';

class PantallaMeses extends StatefulWidget {
  final String nombre;

  PantallaMeses({required this.nombre});

  @override
  _PantallaMesesState createState() => _PantallaMesesState();
}

class _PantallaMesesState extends State<PantallaMeses> {
  final List<String> meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  Set<String> mesesConfirmados = {};

  @override
  void initState() {
    super.initState();
    cargarMesesConfirmados();
  }

  Future<void> cargarMesesConfirmados() async {
    final resultado = await obtenerMesesConDatos(widget.nombre, 2025);
    setState(() {
      mesesConfirmados = resultado;
    });
  }

  Future<Set<String>> obtenerMesesConDatos(String usuario, int anio) async {
    final db = await DBHelper.getDatabase();
    final resultado = await db.query(
      'dias_confirmados',
      where: 'usuario = ? AND anio = ?',
      whereArgs: [usuario, anio],
    );

    return resultado
        .map((row) => row['mes'] as String)
        .toSet(); // meses como '01', '02', etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola ${widget.nombre} 👋'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('nombreUsuario');

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => PantallaBienvenida()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(12, (index) {
            final claveMes = (index + 1).toString().padLeft(2, '0');
            final mesConfirmado = mesesConfirmados.contains(claveMes);

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mesConfirmado ? Colors.green : null,
                padding: EdgeInsets.all(20),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaGenerador(
                      nombre: widget.nombre,
                      mes: index + 1,
                      anio: 2025,
                    ),
                  ),
                );
                // Al volver de la pantalla de generación, recarga el estado
                cargarMesesConfirmados();
              },
              child: Text(
                meses[index],
                style: TextStyle(fontSize: 18),
              ),
            );
          }),
        ),
      ),
    );
  }
}
