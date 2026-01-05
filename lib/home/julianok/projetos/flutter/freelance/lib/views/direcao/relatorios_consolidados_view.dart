import 'package:flutter/material.dart';

class RelatoriosConsolidadosView extends StatefulWidget {
  const RelatoriosConsolidadosView({super.key});

  @override
  State<RelatoriosConsolidadosView> createState() => _RelatoriosConsolidadosViewState();
}

class _RelatoriosConsolidadosViewState extends State<RelatoriosConsolidadosView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Consolidados'),
      ),
      body: const Center(
        child: Text('Conteúdo dos Relatórios Consolidados'),
      ),
    );
  }
}