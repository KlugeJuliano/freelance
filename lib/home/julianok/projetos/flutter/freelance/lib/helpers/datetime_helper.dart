import 'package:flutter/material.dart';

DateTime? dataInicio;
DateTime? dataFim;

Future<DateTime?> selecionarDataHora(BuildContext context) async {
  final data = await showDatePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );

  if (data == null) return null;

  final hora = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (hora == null) return null;

  return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
}
