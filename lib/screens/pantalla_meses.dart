import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db_helper.dart';
import 'pantalla_generador.dart';
import 'pantalla_bienvenida.dart';

class PantallaMeses extends StatefulWidget {
  final String nombre;

  const PantallaMeses({required this.nombre, super.key});

  @override
  State<PantallaMeses> createState() => _PantallaMesesState();
}

class _PantallaMesesState extends State<PantallaMeses> {
  final List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril',
    'Mayo', 'Junio', 'Julio', 'Agosto',
    'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  Set<String> mesesConDatos = {};

  @override
  void initState() {
    super.initState();
    cargarMesesConDatos();
  }

  Future<void> cargarMesesConDatos() async {
    final resultado = await obtenerMesesConDatos(widget.nombre, 2025);
    setState(() {
      mesesConDatos = resultado;
    });
  }

  Future<Set<String>> obtenerMesesConDatos(String usuario, int anio) async {
    final db = await DBHelper.getDatabase();
    final resultado = await db.query(
      'dias_confirmados',
      where: 'usuario = ? AND anio = ?',
      whereArgs: [usuario, anio],
    );

    // Asegura que sean strings tipo '01', '02', etc.
    return resultado
        .map((row) => row['mes'].toString().padLeft(2, '0'))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola ${widget.nombre} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            final numeroMes = (index + 1).toString().padLeft(2, '0');
            final tieneDatos = mesesConDatos.contains(numeroMes);

            return GestureDetector(
              onTap: () async {
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

                // Recargar estados luego de volver
                cargarMesesConDatos();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: tieneDatos ? Colors.green.shade400 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 36,
                      color: tieneDatos ? Colors.white : Colors.indigo,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      meses[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tieneDatos ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
