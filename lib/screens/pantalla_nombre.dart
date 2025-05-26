import 'package:flutter/material.dart';
import '../screens/pantalla_meses.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaNombre extends StatefulWidget {
  @override
  _PantallaNombreState createState() => _PantallaNombreState();
}

class _PantallaNombreState extends State<PantallaNombre> {
  final TextEditingController _controller = TextEditingController();
  String? _nombre = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('¿Cuál es tu nombre?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Ingresa tu nombre para continuar:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _nombre = value.trim();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_nombre != null && _nombre!.isNotEmpty)
                  ? () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('nombreUsuario', _nombre!);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaMeses(nombre: _nombre!),
                  ),
                );
              }
                  : null,
              child: Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}