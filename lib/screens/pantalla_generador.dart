import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
import '../data/db_helper.dart';


//Seleccion de los días
class PantallaGenerador extends StatefulWidget {
  final String nombre;
  final int mes;
  final int anio;

  PantallaGenerador({
    required this.nombre,
    required this.mes,
    required this.anio,
  });

  List<DateTime> diasConfirmadosDesdeBase = [];

  @override
  _PantallaGeneradorState createState() => _PantallaGeneradorState();
}

class _PantallaGeneradorState extends State<PantallaGenerador> {
  List<DateTime> diasPreseleccionados = [];
  List<DateTime> diasConfirmados = [];

  @override
  void initState() {
    super.initState();
    cargarDiasDesdeBD();
  }

  Future<void> cargarDiasDesdeBD() async {
    final dias = await DBHelper.obtenerDiasPorMes(
      usuario: widget.nombre,
      mes: widget.mes,
      anio: widget.anio,
    );

    setState(() {
      diasConfirmados = dias;
    });
  }

  void  generarDiasOficina() async{
    final primerDia = DateTime(widget.anio, widget.mes, 1);
    final ultimoDia = DateTime(widget.anio, widget.mes + 1, 0);
    final random = Random();

    List<DateTime> diasLaborales = [];

    for (int i = 0; i < ultimoDia.day; i++) {
      final dia = primerDia.add(Duration(days: i));
      if (dia.weekday >= DateTime.monday && dia.weekday <= DateTime.friday) {
        diasLaborales.add(dia);
      }
    }

    diasLaborales.shuffle(random);

    List<DateTime> seleccionados = [];
    int lunes = 0;
    int viernes = 0;
    Map<String, int> semanasLocales = {};

    // Agregar los días confirmados de otros meses a la validación


    final diasExternosPorSemana = await obtenerDiasConfirmadosGlobalPorSemana();

    for (var dia in diasLaborales) {
      final lunesSemana = dia.subtract(Duration(days: dia.weekday - 1));
      final claveSemana = '${lunesSemana.year}-${lunesSemana.month}-${lunesSemana.day}';

      if ((dia.weekday == DateTime.monday && lunes >= 1) ||
          (dia.weekday == DateTime.friday && viernes >= 1)) continue;

      final totalSemana = (semanasLocales[claveSemana] ?? 0) +
          (diasExternosPorSemana[claveSemana] ?? 0);

      if (totalSemana >= 3) continue;

      if (dia.weekday == DateTime.monday) lunes++;
      if (dia.weekday == DateTime.friday) viernes++;

      semanasLocales[claveSemana] = (semanasLocales[claveSemana] ?? 0) + 1;
      seleccionados.add(dia);
    }

    seleccionados.sort((a, b) => a.compareTo(b));

    setState(() {
      diasPreseleccionados = seleccionados;
      diasConfirmados = []; // reset
    });
  }

  Future<Map<String, int>> obtenerDiasConfirmadosGlobalPorSemana() async {
    final db = await DBHelper.getDatabase();
    final resultado = await db.query('dias_confirmados');

    Map<String, int> conteoPorSemana = {};

    for (var fila in resultado) {
      final fecha = DateTime.parse(fila['fecha'] as String);
      final lunesSemana = fecha.subtract(Duration(days: fecha.weekday - 1));
      final claveSemana = '${lunesSemana.year}-${lunesSemana.month}-${lunesSemana.day}';

      conteoPorSemana[claveSemana] = (conteoPorSemana[claveSemana] ?? 0) + 1;
    }

    return conteoPorSemana;
  }

  bool esDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool estaPreseleccionado(DateTime dia) {
    return diasPreseleccionados.any((d) => esDia(d, dia));
  }

  bool estaConfirmado(DateTime dia) {
    return diasConfirmados.any((d) => esDia(d, dia));
  }

  CalendarStyle _calendarStyle(DateTime day) {
    if (estaConfirmado(day)) {
      return CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.white),
        todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      );
    } else if (estaPreseleccionado(day)) {
      return CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.black),
        todayDecoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
      );
    } else {
      return CalendarStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicioMes = DateTime(widget.anio, widget.mes, 1);
    final finMes = DateTime(widget.anio, widget.mes + 1, 0);

    final nombreMes = [
      'Enero', 'Febrero', 'Marzo', 'Abril',
      'Mayo', 'Junio', 'Julio', 'Agosto',
      'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ][widget.mes - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('$nombreMes ${widget.anio}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Hola ${widget.nombre}, estos son tus días laborales:'),
            const SizedBox(height: 16),
            TableCalendar(
              locale: 'es_ES',
              firstDay: inicioMes,
              lastDay: finMes,
              focusedDay: inicioMes,
              headerVisible: false,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (estaConfirmado(day)) {
                    return _buildDiaColor(day, Colors.green);
                  } else if (estaPreseleccionado(day)) {
                    return _buildDiaColor(day, Colors.amber);
                  } else {
                    return null;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (diasConfirmados.isNotEmpty) {
                        // Si ya hay días confirmados → limpiar
                        await DBHelper.eliminarDiasPorMes(
                          usuario: widget.nombre,
                          mes: widget.mes,
                          anio: widget.anio,
                        );
                        setState(() {
                          diasConfirmados.clear();
                          diasPreseleccionados.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Días eliminados para este mes')),
                        );
                      } else {
                        // Si no hay días confirmados → generar nuevos
                        generarDiasOficina();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: diasConfirmados.isNotEmpty
                          ? Colors.red.shade400
                          : null, // rojo para "limpiar", color normal para "generar"
                    ),
                    child: Text(diasConfirmados.isNotEmpty ? 'Limpiar' : 'Generar días'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: diasPreseleccionados.isNotEmpty
                        ? () async {
                      setState(() {
                        diasConfirmados = [...diasPreseleccionados];
                      });

                      for (var dia in diasConfirmados) {
                        await DBHelper.insertarDia(
                          usuario: widget.nombre,
                          fecha: dia,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Días guardados correctamente')),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Guardar'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDiaColor(DateTime day, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}