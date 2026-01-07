import 'package:flutter/material.dart';

Future<DateTime?> selecionarDataHora({
  required BuildContext context,
  DateTime? initialDate,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
  );

  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
