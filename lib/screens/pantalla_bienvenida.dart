import 'package:flutter/material.dart';
import '../screens/pantalla_nombre.dart';

class PantallaBienvenida extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              Text(
                'Bienvenido a Días de Oficina',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Te ayudaremos a planificar tus días de oficina del 2025 de forma ordenada.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PantallaNombre()),
                  );
                },
                child: Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

