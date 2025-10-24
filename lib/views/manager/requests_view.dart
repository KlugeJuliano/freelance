import 'package:flutter/material.dart';
class GerenteView extends StatefulWidget {
  const GerenteView({super.key});

  @override
  State<GerenteView> createState() => _GerenteViewState();
}

class _GerenteViewState extends State<GerenteView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Gerente Page'),
      ),
    );
  }
}
