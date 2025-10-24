import 'package:flutter/material.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filade pedidos'),),
      body: Center(child: Text('RH'),),
    );
  }
}
