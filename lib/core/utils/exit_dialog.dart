import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showExitConfirmDialog(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Salir de Cubamap?'),
      content: const Text('Estás a punto de cerrar la aplicación.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salir'),
        ),
      ],
    ),
  );
  if ((shouldExit ?? false) && context.mounted) {
    await SystemNavigator.pop();
  }
}
