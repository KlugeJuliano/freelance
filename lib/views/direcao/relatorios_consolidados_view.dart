import 'package:flutter/material.dart';
import 'package:freelance/services/relatorio_service.dart';
import 'package:intl/intl.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RelatoriosConsolidadosView extends StatefulWidget {
  const RelatoriosConsolidadosView({super.key});

  @override
  State<RelatoriosConsolidadosView> createState() =>
      _RelatoriosConsolidadosViewState();
}

class _RelatoriosConsolidadosViewState extends State<RelatoriosConsolidadosView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<dynamic> _porLoja = [];
  List<dynamic> _porFuncao = [];
  List<dynamic> _porGerente = [];
  List<dynamic> _porFreelancer = [];
  List<dynamic> _evolucao = [];

  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final results = await Future.wait([
        RelatorioService.gastosPorLoja(),
        RelatorioService.gastosPorFuncao(),
        RelatorioService.gastosPorGerente(),
        RelatorioService.gastosPorFreelancer(),
        RelatorioService.evolucaoCustosLoja(),
      ]);

      setState(() {
        _porLoja = results[0];
        _porFuncao = results[1];
        _porGerente = results[2];
        _porFreelancer = results[3];
        _evolucao = results[4];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar relatórios: $e';
        _loading = false;
      });
    }
  }

  Widget _buildLista({
    required List<dynamic> itens,
    required String Function(Map) titulo,
    required String Function(Map) subtitulo,
    required String Function(Map) valor,
  }) {
    if (itens.isEmpty) {
      return const Center(child: Text('Nenhum dado encontrado'));
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itens.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = itens[index] as Map;
          return ListTile(
            title: Text(
              titulo(item),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitulo(item)),
            trailing: Text(
              _currency.format(double.tryParse(valor(item).toString()) ?? 0),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEvolucao() {
    if (_evolucao.isEmpty) {
      return const Center(child: Text('Nenhum dado encontrado'));
    }

    // Agrupa por loja
    final Map<String, List<dynamic>> porLoja = {};
    for (final item in _evolucao) {
      final nome = item['nome'] as String;
      porLoja.putIfAbsent(nome, () => []).add(item);
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: porLoja.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map((mes) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(mes['mes'] as String),
                          Text(
                            _currency.format(
                              double.tryParse(mes['total_valor'].toString()) ??
                                  0,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Consolidados'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Por Loja'),
            Tab(text: 'Por Função'),
            Tab(text: 'Por Gerente'),
            Tab(text: 'Por Freelancer'),
            Tab(text: 'Evolução'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_erro!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarDados,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(
                  itens: _porLoja,
                  titulo: (i) => i['nome'],
                  subtitulo: (i) =>
                      '${i['total_pedidos']} pedidos · ${i['total_horas']}h',
                  valor: (i) => i['total_valor'],
                ),
                _buildLista(
                  itens: _porFuncao,
                  titulo: (i) => i['nome'],
                  subtitulo: (i) =>
                      '${i['total_pedidos']} pedidos · ${i['total_horas']}h · R\$ ${i['valor_hora']}/h',
                  valor: (i) => i['total_valor'],
                ),
                _buildLista(
                  itens: _porGerente,
                  titulo: (i) => i['nome'],
                  subtitulo: (i) =>
                      '${i['total_pedidos']} pedidos · ${i['total_horas']}h',
                  valor: (i) => i['total_valor'],
                ),
                _buildLista(
                  itens: _porFreelancer,
                  titulo: (i) => i['nome'],
                  subtitulo: (i) =>
                      '${i['total_pedidos']} pedidos · ${i['total_horas']}h',
                  valor: (i) => i['total_valor'],
                ),
                _buildEvolucao(),
              ],
            ),
    );
  }
}
